require 'rails_helper'

module MnoEnterprise
  RSpec.describe 'Admin::Tenant API', type: :request do
    include DeviseRequestSpecHelper
    include RSpec::Rails::ViewRendering
    render_views

    before { stub_audit_events }
    before { Timecop.freeze(Date.parse('2015-02-15')) }

    let(:tenant) { build(:tenant,  domain: 'tenant.domain.test')}
    let(:user) { build(:user, :admin, mnoe_tenant: tenant) }

    before do
      sign_in(user)

      stub_api_v2(:get, '/tenant', tenant)
      stub_api_v2(:patch, '/tenant', tenant)
    end

    # We need to use a request spec to trigger Rails `deep_munge`
    describe 'PATCH /mnoe/jpi/v1/admin/tenant' do
      let(:tenant_params) { {frontend_config: {}} }
      let(:data) { {tenant: tenant_params} }

      subject { patch '/mnoe/jpi/v1/admin/tenant', data.to_json }

      it 'is successful' do
        subject
        expect(response).to have_http_status(:ok)
      end

      describe 'deep_munge' do
        let(:tenant_params) { { frontend_config: {foo: {bar: []}, config_timestamp: Time.now.to_i } } }

        it 'does not munge the frontend config' do
          allow(MnoEnterprise::Tenant).to receive(:show).and_return(tenant)
          expect(tenant).to receive(:update_attributes).with(tenant_params)
          subject
        end
      end
    end
  end
end
