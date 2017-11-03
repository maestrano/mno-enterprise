require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::DashboardTemplatesController, type: :controller do
    # include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:dashboard_dependencies) { [:widgets, :kpis] }

    let(:user) { build(:user, :admin) }
    let(:organization) { build(:organization) }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:widget) { build(:impac_widget) }
    let(:d_kpi) { build(:impac_kpi) }
    let(:template) do
      build(:impac_dashboard,
            dashboard_type: 'template',
            organization_ids: [organization.uid],
            currency: 'EUR',
            settings: metadata,
            owner_type: nil,
            owner_id: nil,
            published: true,
            widgets: [widget],
            kpis: [d_kpi]
      )
    end

    # TODO: extract to an helper shared across impac specs
    def hash_for_kpi(kpi)
      {
        "id" => kpi.id,
        'settings' => kpi.settings,
        "element_watched" => kpi.element_watched,
        "endpoint" => kpi.endpoint,
        "extra_params" => kpi.extra_params,
        "extra_watchables" => kpi.extra_watchables,
        "source" => kpi.source,
        "targets" => kpi.targets
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
        # "kpis" => [hash_for_kpi(w_kpi)]
      }
    end
    let(:hash_for_template) do
      {
        "id" => template.id,
        "name" => template.name,
        "full_name" => template.full_name,
        "currency" => 'EUR',
        "metadata" => metadata.deep_stringify_keys,
        "data_sources" => [{ "id" => organization.id, "uid" => organization.uid, "label" => organization.name }],
        "kpis" => [hash_for_kpi(d_kpi)],
        "widgets" => [hash_for_widget],
        "published" => true
      }
    end

    before do
      stub_user(user)
      sign_in user
      stub_api_v2(:get, '/organizations', [organization], [], filter: { 'user.ids': user.id })
      stub_audit_events
    end

    describe '#index' do
      subject { get :index }

      before do
        stub_api_v2(:get, "/dashboards", [template], dashboard_dependencies, filter: { 'dashboard_type' => 'template' })
      end

      it_behaves_like "a jpi v1 admin action"

      it 'returns a list of dashboard templates' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_template])
      end
    end

    describe '#show' do
      subject { get :show, id: template.id }

      before do
        stub_api_v2(:get, "/dashboards/#{template.id}", template, dashboard_dependencies)
      end

      it_behaves_like "a jpi v1 admin action"

      it 'returns a dashboard template' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_template)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the template cannot be found' do
        xit 'spec to be described'
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

      before do
        stub_api_v2(:get, "/dashboards/#{template.id}", template, dashboard_dependencies)
        stub_api_v2(:post, '/dashboards', [template])
      end

      # TODO: APIv2
      # it_behaves_like "a jpi v1 admin action"

      it 'creates a dashboard template'

      it 'returns a dashboard template' do
        pending 'APIv2'
        subject
        # TODO: APIv2 => returns kpis and widgets when updating
        resp = hash_for_template.merge("kpis" => [], "widgets" => [])
        expect(JSON.parse(response.body)).to eq(resp)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the dashboard creation is unsuccessful' do
        xit 'spec to be described'
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

      before do
        stub_api_v2(:get, "/dashboards/#{template.id}", template)
        stub_api_v2(:get, "/dashboards/#{template.id}", template, dashboard_dependencies)
        stub_api_v2(:patch, "/dashboards/#{template.id}", [template])
      end

      # TODO: APIv2
      # it_behaves_like "a jpi v1 admin action"

      it 'updates the dashboard template'

      it 'returns a dashboard template' do
        pending 'APIv2'
        subject
        # TODO: APIv2 => returns kpis and widgets when updating
        resp = hash_for_template.merge("kpis" => [], "widgets" => [])
        expect(JSON.parse(response.body)).to eq(resp)
      end

      # api_stub should be modified to allow these cases to be stubbed
      context 'when the template cannot be found' do
        xit 'spec to be described'
      end
      context 'when the dashboard update is unsuccessful' do
        xit 'spec to be described'
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: template.id }

      before do
        stub_api_v2(:get, "/dashboards/#{template.id}", template)
      end
      let!(:stub) { stub_api_v2(:delete, "/dashboards/#{template.id}") }
      it_behaves_like "a jpi v1 admin action"

      it 'deletes the template' do
        subject
        expect(stub).to have_been_requested
      end

      # api_stub should be modified to allow these cases to be stubbed
      context 'when the template cannot be found' do
        xit 'spec to be described'
      end
      context 'when the dashboard destruction is unsuccessful' do
        xit 'spec to be described'
      end
    end
  end
end
