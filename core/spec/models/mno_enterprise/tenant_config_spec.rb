require 'rails_helper'

describe MnoEnterprise::TenantConfig do

  it { expect(described_class).to  respond_to(:json_schema) }

  let(:tenant) { build(:tenant, frontend_config: {'foo' => 'bar'})}

  describe '.load_config!' do
    before { stub_api_v2(:get, '/tenant', tenant) }
    before { stub_api_v2(:get, '/apps', []) }
    before { stub_api_v2(:get, '/products', [], [], { filter: { active: true, local: true }} ) }

    subject { described_class.load_config! }

    it 'fetch the tenant config' do
      expect(described_class).to receive(:fetch_tenant_config)
      subject
    end

    it 'merge the settings' do
      subject
      expect(Settings.foo).to eq('bar')
    end

    it 'reconfigure mnoe' do
      expect(described_class).to receive(:reconfigure_mnoe!)
      subject
    end
  end

  describe '.fetch_tenant_config' do
    subject { described_class.fetch_tenant_config }

    it 'get the tenant config from MnoHub' do
      stub_api_v2(:get, '/tenant', tenant)
      expect(subject).to eq(tenant.frontend_config)
    end

    it 'does not fail on connection error' do
      stub_api_v2(:get, '/tenant').to_timeout
      expect(subject).to be_nil
    end
  end

  describe '.reconfigure_mnoe!' do
    before do
      Settings.system.app_name = 'New App Name'
      Settings.system.email.support_email = 'New Support Email'
      Settings.system.email.default_sender.name = 'New Sender Name'
      Settings.system.email.default_sender.email = 'New Sender Email'
      Settings.system.i18n.enabled = 'New I18n'
      Settings.system.smtp.merge!(address: 'smtp.test')
      described_class.reconfigure_mnoe!
    end

    it { expect(MnoEnterprise.app_name).to eq('New App Name') }
    it { expect(MnoEnterprise.support_email).to eq('New Support Email') }
    it { expect(MnoEnterprise.default_sender_name).to eq('New Sender Name') }
    it { expect(MnoEnterprise.default_sender_email).to eq('New Sender Email') }
    it { expect(MnoEnterprise.i18n_enabled).to eq('New I18n') }
    it do
      expected = {
        # Configured value
        address: 'smtp.test',
        # Default values
        authentication: 'plain',
        port: 25
      }
      expect(Rails.application.config.action_mailer.smtp_settings).to eq(expected)
      expect(ActionMailer::Base.smtp_settings).to eq(expected)
    end
  end

  describe '.refresh_json_schema!' do
    before { stub_api_v2(:get, '/apps', [build(:app, name: 'My App', nid: 'my-app')]) }
    before { stub_api_v2(:get, '/products', [build(:product, name: 'My Product', nid: 'my-product')], [], { filter: { active: true, local: true }} ) }

    subject { described_class.refresh_json_schema!({}) }

    let(:preferred_locale_hash) do
      {
        'enum' => %w(fr-FR en-GB en-AU),
        'x-schema-form' => {
          'titleMap' => {
            'fr-FR' => 'fr-FR',
            'en-GB' => 'English (United Kingdom)',
            'en-AU' => 'English (Australia)'
          }
        }
      }
    end

    let(:available_locales_hash) do
      {
        'x-schema-form' => {
          'titleMap' => {
            'fr-FR' => 'fr-FR',
            'en-GB' => 'English (United Kingdom)',
            'en-AU' => 'English (Australia)'
          }
        }
      }
    end

    let(:available_locale_items_hash) do
      {
        'enum' => %w(fr-FR en-GB en-AU)
      }
    end

    let(:available_app_hash)  do
      {
        'x-schema-form' => {
          'titleMap' => {
            'my-app' => 'My App'
          }
        }
      }
    end

    let(:available_app_items_hash) do
      {
        'enum' => %w(my-app)
      }
    end

    let(:available_local_product_hash)  do
      {
        'x-schema-form' => {
          'titleMap' => {
            'my-product' => 'My Product'
          }
        }
      }
    end

    let(:available_local_product_items_hash) do
      {
        'enum' => %w(my-product)
      }
    end

    it 'refresh the json schema' do
      I18n.available_locales = %w(fr-FR fr en en-GB en-AU)

      subject

      i18n_properties = described_class.json_schema['properties']['system']['properties']['i18n']['properties']

      expect(i18n_properties['preferred_locale']).to include(preferred_locale_hash)
      expect(i18n_properties['available_locales']).to include(available_locales_hash)
      expect(i18n_properties['available_locales']['items']).to include(available_locale_items_hash)

      public_pages_properties = described_class.json_schema['properties']['dashboard']['properties']['public_pages']['properties']
      expect(public_pages_properties['applications']).to include(available_app_hash)
      expect(public_pages_properties['applications']['items']).to include(available_app_items_hash)
      expect(public_pages_properties['highlighted_applications']).to include(available_app_hash)
      expect(public_pages_properties['highlighted_applications']['items']).to include(available_app_items_hash)
      expect(public_pages_properties['local_products']).to include(available_local_product_hash)
      expect(public_pages_properties['local_products']['items']).to include(available_local_product_items_hash)
      expect(public_pages_properties['highlighted_local_products']).to include(available_local_product_hash)
      expect(public_pages_properties['highlighted_local_products']['items']).to include(available_local_product_items_hash)
    end
  end

  describe '.build_object' do
    subject { described_class.build_object(schema.with_indifferent_access) }

    context 'string with default' do
      let(:schema) { {type: "string", default: "Hello World"} }
      let(:output) { 'Hello World' }
      it { is_expected.to eq(output)}
    end

    context 'string without default' do
      let(:schema) { { type: "string" } }
      let(:output) { nil }
      it { is_expected.to eq(output)}
    end

    context 'object' do
      let(:schema) {
        {
          type: "object",
          properties: {
            foo: {
              type: "string",
              default: "Hello World"
            },
            bar: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true
                }
              }
            },
            baz: {
              type: "string"
            }
          }
        }
      }
      let(:output) { {'foo' => 'Hello World', 'bar' => {'enabled' => true} } }
      it { is_expected.to eq(output)}
    end

    context 'array' do
      let(:schema) {
        {
          type: "array",
          items: {
            type: 'string',
            enum: %w(A B C D),
          },
          default: ['A']
        }
      }

      let(:output) { ['A'] }
      it { is_expected.to eq(output)}
    end
  end

  describe '.flag_readonly_fields' do
    subject { described_class.flag_readonly_fields(schema.with_indifferent_access, config) }

    let(:schema) {
      {
        type: "object",
        properties: {
          admin_panel: {
            type: "object",
            properties: {
              audit_log: {
                type: "object",
                properties: {
                  enabled: {
                    type: "boolean",
                    default: true
                  }
                }
              },
              impersonation: {
                type: "object",
                properties: {
                  enabled: {
                    type: "boolean",
                    default: true
                  }
                }
              }
            }

          }
        }
      }
    }

    let(:config) {
      {'admin_panel' => {'audit_log' => {'enabled' => true, 'enabled_readonly' => true}} }
    }

    let(:output) {
      {
        type: "object",
        properties: {
          admin_panel: {
            type: "object",
            properties: {
              audit_log: {
                type: "object",
                properties: {
                  enabled: {
                    type: "boolean",
                    default: true,
                    readonly: true
                  }
                }
              },
              impersonation: {
                type: "object",
                properties: {
                  enabled: {
                    type: "boolean",
                    default: true
                  }
                }
              }
            }
          }
        }
      }
    }

    it { is_expected.to eq(output.with_indifferent_access) }
  end
end
