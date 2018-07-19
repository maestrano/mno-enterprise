require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::WidgetsController, type: :controller do
    # include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:user) { build(:user, :admin, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:template) { build(:impac_dashboard, dashboard_type: 'template') }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:widget) { build(:impac_widget, dashboard: template, settings: metadata) }
    let(:kpi) { build(:impac_kpi, widget: widget) }

    let(:hash_for_kpi) do
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
        'metadata' => metadata.deep_stringify_keys,
        "endpoint" => widget.widget_category,
        "width" => widget.width,
        "kpis" => []
        # TODO: APIv2
        # "kpis" => [hash_for_kpi]
      }
    end

    before do
      stub_user(user)
      sign_in user

      stub_audit_events
    end

    describe '#create' do
      let(:widget_params) do
        {
          endpoint: widget.endpoint,
          name: widget.name,
          width: widget.width,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { post :create, dashboard_template_id: template.id, widget: widget_params }

      before do
        stub_api_v2(:get, "/dashboards/#{template.id}", [template], [], { filter: { 'dashboard_type' => 'template' } })
        stub_api_v2(:post, "/widgets", [widget])
      end

      it_behaves_like "a jpi v1 admin action"
      it_behaves_like "an unauthorized route for support users"

      it 'creates a widget' do
        subject
        assert_requested_api_v2(:post, '/widgets',
                                body: {
                                  data: {
                                    type: 'widgets',
                                    attributes: widget_params
                                                  .slice(:endpoint, :name)
                                                  .merge(
                                                    width: widget_params[:width].to_s,
                                                    settings: metadata,
                                                    widget_category: widget_params[:endpoint],
                                                    dashboard_id: template.id.to_s
                                                  )
                                  }
                                }.to_json)
      end

      it 'returns a widget' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_widget)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the template cannot be found' do
        xit 'spec to be described'
      end
    end

    describe '#update' do
      let(:widget_params) do
        {
          name: widget.name,
          width: 42,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { put :update, id: widget.id, widget: widget_params }

      before do
        stub_api_v2(:get, "/widgets/#{widget.id}", [widget])
        stub_api_v2(:patch, "/widgets/#{widget.id}", [widget])
      end

      it_behaves_like "a jpi v1 admin action"
      it_behaves_like "an unauthorized route for support users"

      it 'updates the widget' do
        subject
        # Only send the changed attributes
        assert_requested_api_v2(:patch, "/widgets/#{widget.id}",
                                body: {
                                  'data' => {
                                    'id' => widget.id,
                                    'type' => 'widgets',
                                    'attributes' => {'width' => '42'}
                                  }
                                }.to_json)
      end

      it 'returns a widget' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_widget)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the widget update is unsuccessful' do
        xit 'spec to be described'
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: widget.id }

      before do
        stub_api_v2(:get, "/widgets/#{widget.id}", [widget])
        stub_api_v2(:delete, "/widgets/#{widget.id}")
      end

      it_behaves_like "a jpi v1 admin action"
      it_behaves_like "an unauthorized route for support users"

      it 'destroys the widget' do
        subject
        assert_requested_api_v2(:delete, "/widgets/#{widget.id}")
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the widget destruction is invalidunsuccessful' do
        xit 'spec to be described'
      end
    end
  end
end
