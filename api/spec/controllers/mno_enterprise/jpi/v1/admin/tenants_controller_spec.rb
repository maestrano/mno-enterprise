require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::TenantsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    # TODO: this should be done for all controllers?
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:tenant) { build(:tenant,  domain: 'tenant.domain.test')}
    let(:user) { FactoryGirl.build(:user, :admin) }

    before do
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      sign_in user

      stub_api_v2(:get, '/tenant', tenant)
      stub_api_v2(:patch, '/tenant', tenant)
    end

    describe 'GET #show' do
      subject { get :show }

      # TODO: fix
      # it_behaves_like 'a jpi v1 admin action'

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template(:show) }

      it 'returns the tenant information' do
        subject
        expected = {
          tenant: {
            domain: 'tenant.domain.test',
            frontend_config: Settings.to_hash,
            plugins_config: {
              payment_gateways: []
            }
          }
        }

        # TODO: using JSON parse for better error
        expect(JSON.parse(response.body)).to eq(JSON.parse(expected.to_json))
      end

    end

    describe 'PATCH #update' do
      # TODO: fix
      # it_behaves_like 'a jpi v1 admin action'

      let(:tenant_params) { {frontend_config: {}} }

      subject { patch :update, tenant: tenant_params }
      it { is_expected.to have_http_status(:ok) }

      it 'restart the app' do
        expect(MnoEnterprise::SystemManager).to receive(:restart)
        subject
      end
    end

    describe 'PATCH #update_domain' do
      let(:tenant_params) { {domain: 'foo.test'} }

      subject { patch :update_domain, tenant: tenant_params }
      it { is_expected.to have_http_status(:ok) }

      it 'updates the domain then restart the app' do
        expect(MnoEnterprise::SystemManager).to receive(:update_domain).with('foo.test').and_return(true).ordered
        expect(MnoEnterprise::SystemManager).to receive(:restart).ordered
        subject
      end

      context 'on Platform error' do
        before { allow(MnoEnterprise::SystemManager).to receive(:update_domain).and_return(false) }

        it { is_expected.to have_http_status(:bad_request) }

        it 'does not restart the app' do
          expect(MnoEnterprise::SystemManager).not_to receive(:restart)
          subject
        end
      end
    end

    describe 'POST #upload_certificates' do
      let(:tenant_params) { {
        domain: 'foo.test',
        certificate: 'my-cert',
        private_key: 'my-private-key',
        ca_bundle: 'my-ca-bundle'
      } }

      subject { post :add_certificates, tenant: tenant_params }
      it { is_expected.to have_http_status(:ok) }

      it 'adds the certificates then restart the app' do
        expect(MnoEnterprise::SystemManager).to receive(:add_ssl_certs).with('foo.test', 'my-cert', 'my-ca-bundle', 'my-private-key').and_return(true).ordered
        subject
      end

      context 'on Platform error' do
        before { allow(MnoEnterprise::SystemManager).to receive(:add_ssl_certs).and_return(false) }

        it { is_expected.to have_http_status(:bad_request) }
      end

    end
  end
end
