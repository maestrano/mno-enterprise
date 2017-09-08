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
        "extra_params" => kpi.extra_params,
        "extra_watchables" => kpi.extra_watchables,
        "source" => kpi.source,
        "targets" => kpi.targets
      }
    end

    before do
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      sign_in user

      stub_audit_events
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
        stub_api_v2(:get, "/dashboards/#{template.id}", [template], [], { filter: { 'dashboard_type' => 'template' } })
        stub_api_v2(:post,"/kpis", [kpi])
      end

      it_behaves_like "a jpi v1 admin action"

      it 'creates a kpi' do
        subject
        assert_requested_api_v2(:post, '/kpis',
                                body: {
                                  data: {
                                    type: 'kpis',
                                    attributes: kpi_params
                                                  .except(:forbidden, :extra_watchables, :metadata)
                                                  .merge(settings: metadata)
                                  }
                                }.to_json)
      end

      it 'returns a kpi' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_kpi)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the template cannot be found' do
        xit 'spec to be described'
      end
    end

    describe '#update' do
      let(:kpi_params) do
        {
          element_watched: 'foobar',
          extra_watchables: kpi.extra_watchables,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { put :update, id: kpi.id, kpi: kpi_params }

      before do
        stub_api_v2(:get, "/kpis/#{kpi.id}", [kpi])
        stub_api_v2(:patch, "/kpis/#{kpi.id}", [kpi])
      end

      it_behaves_like "a jpi v1 admin action"

      it 'updates the kpi' do
        subject
        # Only send the changed attributes
        assert_requested_api_v2(:patch, "/kpis/#{kpi.id}",
                                body: {
                                  'data' => {
                                    'id' => kpi.id,
                                    'type' => 'kpis',
                                    'attributes' => {'element_watched' => 'foobar'}
                                  }
                                }.to_json)
      end

      it 'returns a kpi' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_kpi)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the kpi update is unsuccessful' do
        xit 'spec to be described'
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: kpi.id }

      before do
        stub_api_v2(:get, "/kpis/#{kpi.id}", [kpi])
        stub_api_v2(:delete, "/kpis/#{kpi.id}")
      end

      it_behaves_like "a jpi v1 admin action"

      it 'destroys the kpi' do
        subject
        assert_requested_api_v2(:delete, "/kpis/#{kpi.id}")
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the kpi destruction is unsuccessful' do
        xit 'spec to be described'
      end
    end
  end
end
