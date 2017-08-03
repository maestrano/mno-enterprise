require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::KpisController, type: :controller do
    # include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:user) { build(:user, :admin, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:template) { build(:impac_dashboard, dashboard_type: 'template') }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:kpi) { build(:impac_kpi, dashboard: template, settings: metadata) }

    let(:hash_for_kpi) do
      {
        "id" => kpi.id,
        'settings' => metadata.deep_stringify_keys,
        "element_watched" => kpi.element_watched,
        "endpoint" => kpi.endpoint,
        "alerts" => []
      }
    end

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe '#create' do
      let(:kpi_params) do
        {
          dashboard_id: template.id,
          endpoint: kpi.endpoint,
          source: kpi.source,
          element_watched: kpi.element_watched,
          extra_watchables: kpi.extra_watchables,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { post :create, dashboard_template_id: template.id, kpi: kpi_params }
      
      before do
        api_stub_for(
          get: "/dashboards/#{template.id}",
          params: { filter: { 'dashboard_type' => 'template' } },
          response: from_api(template)
        )
        api_stub_for(
          post: "dashboards/#{template.id}/kpis",
          response: from_api(kpi)
        )
        # Why is Her doing a GET /kpis after doing a POST /kpis?
        api_stub_for(
          get: "dashboards/#{template.id}/kpis",
          response: from_api([kpi])
        )
      end

      it_behaves_like "a jpi v1 admin action"

      it 'returns a kpi' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_kpi)
      end
    end

    describe '#update' do
      let(:kpi_params) do
        {
          element_watched: kpi.element_watched,
          extra_watchables: kpi.extra_watchables,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { put :update, id: kpi.id, kpi: kpi_params }
      
      before do
        api_stub_for(
          get: "kpis/#{kpi.id}",
          response: from_api(kpi)
        )
        api_stub_for(
          put: "/kpis/#{kpi.id}",
          response: from_api(kpi)
        )
      end

      it_behaves_like "a jpi v1 admin action"

      it 'returns a kpi' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_kpi)
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: kpi.id }
      
      before do
        api_stub_for(
          get: "kpis/#{kpi.id}",
          response: from_api(kpi)
        )
        api_stub_for(
          delete: "/kpis/#{kpi.id}",
          response: from_api(nil)
        )
      end

      it_behaves_like "a jpi v1 admin action"
    end
  end
end
