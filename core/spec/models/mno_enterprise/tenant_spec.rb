require 'rails_helper'
module MnoEnterprise
  describe Tenant, type: :model do
    let(:tenant) { build(:tenant) }

    # Test singular resource
    describe '.show' do
      let!(:stub) { stub_api_v2(:get, '/tenant', tenant) }
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
      let(:params) { {frontend_config: {}} }
      let!(:stub) { stub_api_v2(:patch, '/tenant', tenant).with(body: body.to_json) }
      before { tenant.update_attributes(params) }
      it { expect(stub).to have_been_requested }
    end
  end
end
