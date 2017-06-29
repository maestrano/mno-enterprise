require 'rails_helper'

describe MnoEnterprise::TenantConfig do

  it { expect(described_class).to  be_const_defined(:CONFIG_JSON_SCHEMA) }

  let(:tenant) { build(:tenant, frontend_config: {'foo' => 'bar'})}

  describe '.load_config!' do
    before { stub_api_v2(:get, '/tenant', tenant) }
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
      Settings.system.smtp_settings = {address: 'smtp.test'}
      described_class.reconfigure_mnoe!
    end

    it { expect(MnoEnterprise.app_name).to eq('New App Name') }
    it { expect(MnoEnterprise.support_email).to eq('New Support Email') }
    it { expect(MnoEnterprise.default_sender_name).to eq('New Sender Name') }
    it { expect(MnoEnterprise.default_sender_email).to eq('New Sender Email') }
    it { expect(MnoEnterprise.i18n_enabled).to eq('New I18n') }
    it { expect(Rails.application.config.action_mailer.smtp_settings).to eq({address: 'smtp.test'}) }
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
  end
end
