require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::DashboardsController, type: :controller do
    # include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }


    # =============================================================================================================
    # TODO: DRY
    # =============================================================================================================

    RSpec.shared_context "#{described_class}: dashboard dependencies stubs" do
      before do
        api_stub_for(
          get: "/organizations?filter[uid.in][]=#{org.uid}",
          response: from_api([org])
        )
        api_stub_for(
          get: "/dashboards/#{dashboard.id}/widgets",
          response: from_api([widget])
        )
        api_stub_for(
          get: "/dashboards/#{dashboard.id}/kpis",
          response: from_api([d_kpi])
        )
        api_stub_for(
          get: "/widgets/#{widget.id}/kpis",
          response: from_api([w_kpi])
        )
      end
    end

    let(:user) { build(:user, :admin, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:dashboard) { build(:impac_dashboard, dashboard_type: 'dashboard', organization_ids: [org.uid], currency: 'EUR', settings: metadata) }
    let(:widget) { build(:impac_widget, dashboard: dashboard, owner: user) }
    let(:d_kpi) { build(:impac_kpi, dashboard: dashboard) }
    let(:w_kpi) { build(:impac_kpi, widget: widget) }

    def hash_for_kpi(kpi)
      {
        "id" => kpi.id,
        "element_watched" => kpi.element_watched,
        "endpoint" => kpi.endpoint
      }
    end
    let(:hash_for_widget) do
      {
        "id" => widget.id,
        "name" => widget.name,
        "endpoint" => widget.widget_category,
        "width" => widget.width,
        "kpis" => [hash_for_kpi(w_kpi)]
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

    # =============================================================================================================

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe 'GET #index' do
      subject { get :index }

      before do
        api_stub_for(
          get: '/dashboards',
          params: { filter: { 'owner_type' => 'User', 'owner_id' => user.id } },
          response: from_api([dashboard])
        )
      end

      include_context "#{described_class}: dashboard dependencies stubs"

      it_behaves_like "a jpi v1 admin action"

      it 'returns a list of dashboards' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_dashboard])
      end
    end

    describe 'POST #create' do
      subject { post :create, dashboard: dashboard_params }

      let(:dashboard_params) do
        {
          name: dashboard.name,
          currency: dashboard.currency,
          organization_ids: [org.id]
        }
      end

      before do
        # TODO: stub params?
        api_stub_for(
          post: "/dashboards",
          response: from_api(dashboard)
        )
      end

      include_context "#{described_class}: dashboard dependencies stubs"

      it_behaves_like "a jpi v1 admin action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end

    end

    describe 'PUT #update' do
      subject { put :update, id: dashboard.id, dashboard: dashboard_params }

      let(:dashboard_params) do
        {
          name: dashboard.name,
          currency: dashboard.currency,
          organization_ids: [org.id]
        }
      end

      before do
        api_stub_for(
          get: "/dashboards",
          params: {
            filter: { 'id' => dashboard.id, 'owner_id' => user.id, 'owner_type' => 'User' },
            limit: 1
          },
          response: from_api([dashboard])
        )
        api_stub_for(
          put: "/dashboards/#{dashboard.id}",
          response: from_api(dashboard)
        )
      end

      include_context "#{described_class}: dashboard dependencies stubs"

      it_behaves_like "a jpi v1 admin action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe 'DELETE destroy' do
      subject { delete :destroy, id: dashboard.id }

      before do
        api_stub_for(
          get: "/dashboards",
          params: {
            filter: { 'id' => dashboard.id, 'owner_id' => user.id, 'owner_type' => 'User' },
            limit: 1
          },
          response: from_api([dashboard])
        )
        api_stub_for(
          delete: "/dashboards/#{dashboard.id}",
          response: from_api(nil)
        )
      end

      it_behaves_like "a jpi v1 admin action"
    end

    describe 'POST copy' do
      subject { post :copy, id: template.id, dashboard: dashboard_params }

      let(:template) { build(:impac_dashboard, dashboard_type: 'template') }
      let(:dashboard_params) do
        {
          name: dashboard.name,
          currency: dashboard.currency,
          organization_ids: [org.id]
        }
      end

      before do
        api_stub_for(
          get: "/dashboards/#{template.id}",
          params: { filter: { 'dashboard_type' => 'template' } },
          response: from_api(template)
        )
        api_stub_for(
          post: "/dashboards/#{template.id}/copy",
          response: from_api(dashboard)
        )
      end

      include_context "#{described_class}: dashboard dependencies stubs"

      it_behaves_like "a jpi v1 admin action"
    end
  end
end
