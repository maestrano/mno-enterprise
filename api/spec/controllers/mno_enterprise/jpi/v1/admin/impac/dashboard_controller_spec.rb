require 'rails_helper'
require 'mno_enterprise/testing_support/shared_contexts/jpi_v1_admin_controller'
require 'mno_enterprise/testing_support/shared_contexts/jpi_v1_admin_impac_controller'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::DashboardsController, type: :controller do
    include_context MnoEnterprise::Jpi::V1::Admin::BaseResourceController

    include MnoEnterprise::TestingSupport::SharedContexts::JpiV1AdminImpacController
    include_context 'MnoEnterprise::Jpi::V1::Admin::Impac'

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
