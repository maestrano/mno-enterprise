require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::Impac::DashboardsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { Rails.cache.clear }

    let(:dashboard_dependencies) { [:widgets, :'widgets.kpis', :kpis, :'kpis.alerts'] }

    # Stub user and user call
    let(:org) { build(:organization, users: [], orga_relations: []) }
    let!(:user) { build(:user, organizations: [org]) }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:d_kpi) { build(:impac_kpi) } #, dashboard: dashboard
    let(:w_kpi) { build(:impac_kpi) }
    let(:widget) { build(:impac_widget, owner: user) }

    let(:dashboard) do
      build(:impac_dashboard,
            dashboard_type: 'dashboard',
            organization_ids: [org.uid],
            currency: 'EUR',
            settings: metadata,
            widgets: [widget],
            kpis: [d_kpi]
      )
    end

    let(:dashboard_params) do
      {
        name: dashboard.name,
        currency: dashboard.currency,
        widgets_order: [3, 2, 1],
        organization_ids: [4, 5],
        metadata: metadata,
        forbidden: 'param'
      }
    end

    def hash_for_kpi(kpi)
      {
        "id" => kpi.id,
        "element_watched" => kpi.element_watched,
        "endpoint" => kpi.endpoint,
        "source" => kpi.source,
        "targets" => kpi.targets,
        "settings" => kpi.settings,
        "extra_watchables" => kpi.extra_watchables,
        "extra_params" => kpi.extra_params
      }
    end
    let(:hash_for_widget) do
      {
        "id" => widget.id,
        "name" => widget.name,
        "endpoint" => widget.widget_category,
        "width" => widget.width,
        "kpis" => []
        # TODO: APIv2
        # "kpis" => [hash_for_kpi(w_kpi)],
        # 'owner' => from_api(user)[:data]
      }
    end
    let(:hash_for_dashboard) do
      {
        "id" => dashboard.id,
        "name" => dashboard.name,
        "full_name" => dashboard.full_name,
        "currency" => 'EUR',
        "metadata" => metadata.deep_stringify_keys,
        "data_sources" => [{ "id" => org.id, "uid" => org.uid, "label" => org.name}],
        "kpis" => [hash_for_kpi(d_kpi)],
        "widgets" => [hash_for_widget]
      }
    end

    before do
      sign_in user
      stub_audit_events
    end

    describe 'GET #index' do
      subject { get :index }

      before do
        stub_api_v2(:get, "/dashboards", [dashboard], dashboard_dependencies, {filter: {owner_id: user.id}})
      end

      it_behaves_like "jpi v1 protected action"

      it 'returns a list of dashboards' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_dashboard])
      end
    end

    describe 'GET #show' do
      before do
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", dashboard, [:widgets, :'widgets.kpis', :kpis, :'kpis.alerts'], {filter: {owner_id: user.id}})
      end

      subject { get :show, id: dashboard.id }

      it_behaves_like "jpi v1 protected action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe 'POST #create' do
      before do
        stub_api_v2(:post, "/dashboards", [dashboard])
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", [dashboard], dashboard_dependencies)
      end

      subject { post :create, user_id: user.id, dashboard: dashboard_params }

      it_behaves_like "jpi v1 protected action"

      it '[APIv2] creates a dashboard' do
        pending 'assert_requested'
        fail
      end

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe 'PUT #update' do
      before do
        # TODO: APIv2 Improve contrroller code to do less requests?
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", [dashboard], dashboard_dependencies)
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", [dashboard], [], filter: {owner_id: user.id})
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", [dashboard], dashboard_dependencies, filter: {owner_id: user.id})
        stub_api_v2(:patch, "/dashboards/#{dashboard.id}", [dashboard])
      end

      subject { put :update, id: dashboard.id, dashboard: dashboard_params }

      it_behaves_like "jpi v1 protected action"

      it '[APIv2] updates the dashboard' do
        pending 'assert_requested'
        fail
      end

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe "DELETE destroy" do
      before do
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", [dashboard], [], filter: {owner_id: user.id})
        stub_api_v2(:delete, "/dashboards/#{dashboard.id}")
      end

      subject { delete :destroy, id: dashboard.id }

      it_behaves_like "jpi v1 protected action"

      it 'deletes the dashboard' do
        subject
        assert_requested_api_v2(:delete, "/dashboards/#{dashboard.id}")
      end
    end

    describe 'POST copy' do
      let(:template) { build(:impac_dashboard, dashboard_type: 'template') }

      before do
        stub_api_v2(:get, "/dashboards/#{template.id}", [template], [], filter: { 'dashboard_type' => 'template' })
        stub_api_v2(:post, "/dashboards/#{template.id}/copy", [dashboard])
        stub_api_v2(:get, "/dashboards/#{dashboard.id}", [dashboard], dashboard_dependencies)
      end

      subject { post :copy, id: template.id, dashboard: dashboard_params }

      it_behaves_like "jpi v1 protected action"

      it '[APIv2] copy the dashboard' do
        pending 'assert_requested'
        fail
      end

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end
  end
end
