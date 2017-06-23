require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::TenantsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    # TODO: this should be done for all controllers?
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:tenant) { build(:tenant )}
    let(:user) { FactoryGirl.build(:user, :admin) }

    before do
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      sign_in user

      stub_api_v2(:get, '/tenant', tenant)
    end

    describe 'GET #show' do
      subject { get :show }

      # TODO: fix
      # it_behaves_like 'a jpi v1 admin action'

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template(:show) }

      it 'returns the frontend config' do
        subject
        expected = {
          tenant: {
            frontend_config: Settings.to_hash
          }
        }

        # TODO: using JSON parse for better error
        expect(JSON.parse(response.body)).to eq(JSON.parse(expected.to_json))
      end

    end

    describe 'PATCH #update' do
      before {
        stub_api_v2(:patch, '/tenant', tenant)
      }

      # TODO: fix
      # it_behaves_like 'a jpi v1 admin action'

      let(:tenant_params) { {frontend_config: {}} }

      subject { patch :update, tenant: tenant_params }
      it { is_expected.to have_http_status(:ok) }

      it 'restart the app' do
        expect(MnoEnterprise::AppManager).to receive(:restart)
        subject
      end
    end
  end
end
