require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::Impac::DashboardsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { Rails.cache.clear }

    RSpec.shared_context "#{described_class}: dashboard dependencies stubs" do
      before do
        api_stub_for(
          get: "/users/#{user.id}/organizations",
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
        api_stub_for(
          get: "/kpis/#{w_kpi.id}/alerts",
          response: from_api([])
        )
        api_stub_for(
          get: "/kpis/#{d_kpi.id}/alerts",
          response: from_api([])
        )
      end
    end

    let(:user) { build(:user, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:dashboard) { build(:impac_dashboard, dashboard_type: 'dashboard', organization_ids: [org.uid], currency: 'EUR', settings: metadata) }
    let(:widget) { build(:impac_widget, dashboard: dashboard, owner: user) }
    let(:d_kpi) { build(:impac_kpi, dashboard: dashboard) }
    let(:w_kpi) { build(:impac_kpi, widget: widget) }

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
        "endpoint" => kpi.endpoint
      }
    end
    let(:hash_for_widget) do
      {
        "id" => widget.id,
        "name" => widget.name,
        "endpoint" => widget.widget_category,
        "width" => widget.width,
        "kpis" => [hash_for_kpi(w_kpi)],
        'owner' => from_api(user)[:data]
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
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe 'GET #index' do
      subject { get :index }
      
      before do
        api_stub_for(
          get: "users/#{user.id}/dashboards",
          response: from_api([dashboard])
        )
      end
      include_context "#{described_class}: dashboard dependencies stubs"

      it_behaves_like "jpi v1 protected action"

      it 'returns a list of dashboards' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_dashboard])
      end
    end

    describe 'GET #show' do
      before do
        api_stub_for(
          get: "users/#{user.id}/dashboards/#{dashboard.id}",
          response: from_api(dashboard)
        )
      end
      include_context "#{described_class}: dashboard dependencies stubs"

      subject { get :show, id: dashboard.id }

      it_behaves_like "jpi v1 protected action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe 'POST #create' do
      before do
        api_stub_for(
          post: "users/#{user.id}/dashboards",
          response: from_api(dashboard)
        )
        # Her calling GET /dashboards after a POST...
        api_stub_for(
          get: "users/#{user.id}/dashboards",
          response: from_api([dashboard])
        )
      end
      include_context "#{described_class}: dashboard dependencies stubs"

      subject { post :create, user_id: user.id, dashboard: dashboard_params }

      it_behaves_like "jpi v1 protected action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe 'PUT #update' do
      before do
        api_stub_for(
          get: "users/#{user.id}/dashboards/#{dashboard.id}",
          response: from_api(dashboard)
        )
        api_stub_for(
          put: "dashboards/#{dashboard.id}",
          response: from_api(dashboard)
        )
      end
      include_context "#{described_class}: dashboard dependencies stubs"

      subject { put :update, id: dashboard.id, dashboard: dashboard_params }

      it_behaves_like "jpi v1 protected action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end

    describe "DELETE destroy" do
      before do
        api_stub_for(
          get: "users/#{user.id}/dashboards/#{dashboard.id}",
          response: from_api(dashboard)
        )
        api_stub_for(
          delete: "dashboards/#{dashboard.id}",
          response: from_api(dashboard)
        )
      end
      include_context "#{described_class}: dashboard dependencies stubs"

      subject { delete :destroy, id: dashboard.id }
      
      it_behaves_like "jpi v1 protected action"
    end

    describe 'POST copy' do
      let(:template) { build(:impac_dashboard, dashboard_type: 'template') }

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

      subject { post :copy, id: template.id, dashboard: dashboard_params }

      it_behaves_like "jpi v1 protected action"

      it 'returns a dashboard' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_dashboard)
      end
    end
  end
end
