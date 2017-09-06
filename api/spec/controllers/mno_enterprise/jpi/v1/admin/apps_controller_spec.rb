require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }
    before do
      sign_in user
    end

    # Common stub
    let(:app) { build(:app) }

    describe 'GET #index' do
      before { stub_api_v2(:get, '/apps', [app], [], {fields: {apps: [:name, :id, :logo, :nid, :tiny_description].join(',')}, filter: {scope: 'all'}}) }

      subject { get :index }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'PATCH #enable' do
      let(:params) { {} }

      subject { patch :enable, params}

      context 'without id or ids' do
        it { is_expected.to have_http_status(:bad_request) }
      end

      context 'with an id' do
        let(:params) { {id: app.id} }

        context 'when the App does not exist' do
          before { stub_api_v2_error(:patch, "/apps/#{app.id}/enable", 404, 'Record not found') }

          it { is_expected.to have_http_status(:not_found) }
        end

        context 'when the App exists' do
          before { stub_api_v2(:patch, "/apps/#{app.id}/enable", nil) }

          it_behaves_like 'a jpi v1 admin action'

          it 'makes to correct request to MnoHub' do
            subject
            assert_requested_api_v2(:patch, "/apps/#{app.id}/enable")
          end
        end
      end

      context 'with an ids' do
        let(:params) { {ids: [app.id]} }

        context 'when the Apps do not exist' do
          before { stub_api_v2_error(:patch, "/apps/enable", 404, 'Record not found') }
          it { is_expected.to have_http_status(:not_found) }
        end

        context 'when the Apps exist' do
          before { stub_api_v2(:patch, "/apps/enable", nil) }

          it_behaves_like 'a jpi v1 admin action'

          it 'makes to correct request to MnoHub' do
            subject
            assert_requested_api_v2(:patch, "/apps/enable", body: params.to_json)
          end
        end
      end
    end

    describe 'PATCH #disable' do
      subject { patch :disable, id: app.id }

      context 'when the app is enabled' do
        before { stub_api_v2(:patch, "/apps/#{app.id}/disable", nil) }

        it_behaves_like 'a jpi v1 admin action'

        it 'makes to correct request to MnoHub' do
          subject
          assert_requested_api_v2(:patch, "/apps/#{app.id}/disable")
        end
      end

      context 'when the app is disabled' do
        before { stub_api_v2_error(:patch, "/apps/#{app.id}/disable", 404, 'Record not found') }

        it { is_expected.to have_http_status(:not_found) }
      end
    end
  end
end
