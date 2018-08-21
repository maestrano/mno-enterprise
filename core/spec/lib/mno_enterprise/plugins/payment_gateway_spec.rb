# frozen_string_literal: true

require "rails_helper"

describe MnoEnterprise::Plugins::PaymentGateway do
  include MnoEnterprise::TestingSupport::SharedExamples::Plugins

  it_behaves_like MnoEnterprise::Plugins::Base

  describe 'instance methods' do
    let(:tenant) { build(:tenant) }
    let(:config) { {} }
    let(:plugin) { described_class.new(tenant, config) }

    let(:full_json_config) do
      {
        "payment_gateways": [
          {
            "name": "my_gateway",
            "provider": {
              "adapter": "braintree",
              "config": {
                "merchant_id": "braintree-merchant-id",
                "public_key": "braintree-public-key",
                "private_key": "braintree-private-key"
              }
            },
            "accounts": [
              {
                "american_express": false,
                "jcb": false,
                "currency": "AED",
                "acct": "name-of-AED-merchant-account",
                "default": 2
              }
            ]
          }
        ]
      }.with_indifferent_access
    end

    let(:backend_config) do
      {
        "providers": {
          "my_gateway": {
            "adapter": "braintree",
            "config": {
              "merchant_id": "braintree-merchant-id",
              "public_key": "braintree-public-key",
              "private_key": "braintree-private-key"
            }
          }
        },
        "accounts": {
          "my_gateway": {
            "AED": {
              "american_express": false,
              "jcb": false,
              "acct": "name-of-AED-merchant-account",
              "default": 2
            }
          }
        }
      }.with_indifferent_access
    end

    describe '#show_config' do
      let(:keystore) { { payment_gateways: backend_config }.with_indifferent_access }

      let(:tenant) { build(:tenant, keystore: keystore) }

      let(:expected) { full_json_config }

      subject { plugin.show_config }

      it { is_expected.to eq(expected) }

      context 'with an empty keystore' do
        let(:keystore) { {} }
        it { is_expected.to eq({ "payment_gateways" => [] }) }
      end
    end

    describe '#transform' do
      let(:config) { full_json_config }

      let(:expected) { backend_config }

      subject { plugin.transform }

      it { is_expected.to eq(expected) }
    end

    describe '#save' do
      let(:config) { full_json_config }
      let(:tenant) { build(:tenant, keystore: {'foo' => 'bar'}) }
      subject { plugin.save }

      it 'update the keystore field' do
        subject
        expect(tenant.keystore).to include('payment_gateways')
      end

      it 'marks the keystore field as dirty' do
        subject
        expect(tenant.attribute_changed?(:keystore)).to be true
      end
    end
  end
end
