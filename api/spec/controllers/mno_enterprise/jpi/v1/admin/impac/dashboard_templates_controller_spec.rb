require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::DashboardTemplatesController, type: :controller do
    # include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    RSpec.shared_context "#{described_class}: dashboard dependencies stubs" do
      before do
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
      end
    end

    let(:user) { build(:user, :admin, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:template) { build(:impac_dashboard, dashboard_type: 'template', organization_ids: [org.uid], currency: 'EUR', settings: metadata, owner_type: nil, owner_id: nil, published: true) }
    let(:widget) { build(:impac_widget, dashboard: template) }
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
        "kpis" => [hash_for_kpi(w_kpi)]
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
        "widgets" => [hash_for_widget],
        "published" => true
      }
    end

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end
      
    describe '#index' do
      subject { get :index }
      
      before do
        api_stub_for(
          get: '/dashboards',
          params: { filter: { 'dashboard_type' => 'template' } },
          response: from_api([template])
        )
      end
      include_context "#{described_class}: dashboard dependencies stubs"

      it_behaves_like "a jpi v1 admin action"

      it 'returns a list of dashboard templates' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_template])
      end
    end

    describe '#show' do
      subject { get :show, id: template.id }

      context 'when the template exists' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            response: from_api(template)
          )
        end
        include_context "#{described_class}: dashboard dependencies stubs"

        it_behaves_like "a jpi v1 admin action"

        it 'returns a dashboard template' do
          subject
          expect(JSON.parse(response.body)).to eq(hash_for_template)
        end
      end

      context 'when the template does not exist' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            code: 404
          )
        end

        it 'returns an error message' do
          subject
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'message' => 'Dashboard template not found' } })
        end
      end
    end

    describe '#create' do
      let(:template_params) do
        {
          name: template.name,
          currency: template.currency,
          widgets_order: [3, 2, 1],
          organization_ids: [4, 5],
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { post :create, dashboard: template_params }

      context 'when the dashboard creation is successful' do
        before do
          api_stub_for(
            post: "/dashboards",
            response: from_api(template)
          )
        end
        include_context "#{described_class}: dashboard dependencies stubs"

        it_behaves_like "a jpi v1 admin action"

        it 'returns a dashboard template' do
          subject
          expect(JSON.parse(response.body)).to eq(hash_for_template)
        end
      end

      context 'when the dashboard creation is unsuccessful' do
        before do
          api_stub_for(
            post: "/dashboards",
            code: 400,
            response: { errors: [{ attribute: "name", value: "can't be blank" }] }
          )
        end

        it 'returns an error message' do
          subject
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'name' => ["can't be blank"] } })
        end
      end
    end

    describe '#update' do
      let(:template_params) do
        {
          name: template.name,
          currency: template.currency,
          widgets_order: [3, 2, 1],
          organization_ids: [4, 5],
          metadata: metadata,
          forbidden: 'param',
          published: true
        }
      end

      subject { put :update, id: template.id, dashboard: template_params }

      context 'when the template exists' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            response: from_api(template)
          )
          api_stub_for(
            put: "/dashboards/#{template.id}",
            response: from_api(template)
          )
        end
        include_context "#{described_class}: dashboard dependencies stubs"

        it_behaves_like "a jpi v1 admin action"

        it 'returns a dashboard template' do
          subject
          expect(JSON.parse(response.body)).to eq(hash_for_template)
        end
      end

      context 'when the template does not exist' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            code: 404
          )
        end

        it 'returns an error message' do
          subject
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'message' => 'Dashboard template not found' } })
        end
      end

      context 'when the dashboard update is unsuccessful' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            response: from_api(template)
          )
          api_stub_for(
            put: "/dashboards/#{template.id}",
            code: 400,
            response: { errors: [{ attribute: "name", value: "can't be blank" }] }
          )
        end

        it 'returns an error message' do
          subject
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'name' => ["can't be blank"] } })
        end
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: template.id }

      context 'when the template exists' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            response: from_api(template)
          )
          api_stub_for(
            delete: "/dashboards/#{template.id}",
            response: from_api(nil)
          )
        end

        it_behaves_like "a jpi v1 admin action"
      end

      context 'when the template does not exist' do
        before do
          api_stub_for(
            get: "/dashboards/#{template.id}",
            params: { filter: { 'dashboard_type' => 'template' } },
            code: 404
          )
        end

        it 'returns an error message' do
          subject
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'message' => 'Dashboard template not found' } })
        end
      end
    end
  end
end
