require 'rails_helper'
require 'mno_enterprise/testing_support/shared_contexts/jpi_v1_admin_controller'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::KpisController, type: :controller do
    include_context MnoEnterprise::Jpi::V1::Admin::BaseResourceController

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
        "endpoint" => kpi.endpoint
      }
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

      context 'when the template exists' do
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
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'message' => 'Dashboard template not found' } })
        end
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

      context 'when the kpi exists' do
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

      context 'when the kpi does not exist' do
        before do
          api_stub_for(
            get: "kpis/#{kpi.id}",
            code: 404
          )
        end

        it 'returns an error message' do
          subject
          expect(JSON.parse(response.body)).to eq({ 'errors' => 'Cannot update kpi' })
        end
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: kpi.id }

      context 'when the kpi exists' do
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

      context 'when the kpi does not exist' do
        before do
          api_stub_for(
            get: "kpis/#{kpi.id}",
            code: 404
          )
        end

        it 'returns an error message' do
          subject
          expect(JSON.parse(response.body)).to eq({ 'errors' => 'Cannot delete kpi' })
        end
      end
    end
  end
end
