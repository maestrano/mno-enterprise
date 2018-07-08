require 'rails_helper'
module MnoEnterprise
  describe Tenant, type: :model do
    let(:tenant) { build(:tenant) }

    # Test singular resource
    describe '.show' do
      let!(:stub) { stub_api_v2(:get, '/tenant', tenant, [:tenant_company]) }
      before { described_class.show }
      it { expect(stub).to have_been_requested }
    end

    # Test singular resource
    describe '.update_attributes' do
      let(:body) {{
        data:{
          id: tenant.id,
          type: 'tenants',
          attributes: {
            name: tenant.name,
            domain: tenant.domain
          }.merge(params)
        }
      }}
      let(:params) { {frontend_config: {}, metadata: {app_management: "marketplace", can_manage_organization_credit: true}, tenant_company: nil } }
      let!(:stub) { stub_api_v2(:patch, '/tenant', tenant).with(body: body.to_json) }
      before { tenant.update_attributes(params) }
      it { expect(stub).to have_been_requested }
    end

    describe '.plugins_config=' do
      let(:config) do
        {
          payment_gateways: {
            foo: 'bar'
          }
        }.with_indifferent_access
      end
      let(:plugin) { double('payment_gateway', valid?: true, save: nil) }
      subject { tenant.plugins_config = config }

      before { allow(MnoEnterprise::Plugins::PaymentGateway).to receive(:new).and_return(plugin) }

      it 'instantiates the plugins' do
        expect(MnoEnterprise::Plugins::PaymentGateway).to receive(:new).with(tenant, config).and_return(plugin)
        subject
      end

      it 'save the config' do
        expect(plugin).to receive(:save)
        subject
      end
    end
  end
end
