require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::Impac::DashboardTemplatesController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { Rails.cache.clear }

    let(:user) { build(:user, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:template) { build(:impac_dashboard, dashboard_type: 'template', organization_ids: [org.uid], currency: 'EUR', settings: metadata) }
    let(:widget) { build(:impac_widget, dashboard: template, owner: user) }
    let(:d_kpi) { build(:impac_kpi, dashboard: template) }
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
        "kpis" => [hash_for_kpi(w_kpi)],
        'owner' => from_api(user)[:data]
      }
    end
    let(:hash_for_template) do
      {
        "id" => template.id,
        "name" => template.name,
        "full_name" => template.full_name,
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
          get: '/dashboards',
          params: { filter: { 'dashboard_type' => 'template' } },
          response: from_api([template])
        )
        api_stub_for(
          get: "/users/#{user.id}/organizations",
          response: from_api([org])
        )
        api_stub_for(
          get: "/dashboards/#{template.id}/widgets",
          response: from_api([widget])
        )
        api_stub_for(
          get: "/dashboards/#{template.id}/kpis",
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

      it_behaves_like "jpi v1 protected action"

      it 'returns a list of dashboard templates' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_template])
      end
    end
  end
end
