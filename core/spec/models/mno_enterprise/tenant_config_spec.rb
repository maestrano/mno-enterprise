require 'rails_helper'

describe MnoEnterprise::TenantConfig do

  it { expect(described_class).to  be_const_defined(:CONFIG_JSON_SCHEMA) }


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
