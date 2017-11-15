require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::Impac::DashboardTemplatesController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { Rails.cache.clear }

    let(:dashboard_dependencies) { %w(widgets widgets.kpis kpis kpis.alerts) }

    let(:user) { build(:user) }
    let(:organization) { build(:organization)}
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }

    let(:widget) { build(:impac_widget, owner: user) }
    let(:d_kpi) { build(:impac_kpi) }
    let(:w_kpi) { build(:impac_kpi, widget: widget) }
    let(:template) do
      build(:impac_dashboard,
            dashboard_type: 'template',
            organization_ids: [organization.uid],
            currency: 'EUR',
            settings: metadata,
            widgets: [widget],
            kpis: [d_kpi]
      )
    end

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
        # 'owner' => from_api(user)[:data],
        "kpis" => []
        # TODO: APIv2
        # "kpis" => [hash_for_kpi(w_kpi)],
      }
    end
    let(:hash_for_template) do
      {
        "id" => template.id,
        "name" => template.name,
        "full_name" => template.full_name,
        "currency" => 'EUR',
        "metadata" => metadata.deep_stringify_keys,
        "data_sources" => [{ "id" => organization.id, "uid" => organization.uid, "label" => organization.name}],
        "kpis" => [hash_for_kpi(d_kpi)],
        "widgets" => [hash_for_widget]
      }
    end

    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }

      before do
        stub_api_v2(:get, '/organizations', [organization], [], filter: { 'users.id': user.id})
        stub_api_v2(:get, '/dashboards', [template], dashboard_dependencies, filter: { dashboard_type: 'template', published: true})
      end

      it_behaves_like "jpi v1 protected action"

      it 'returns a list of dashboard templates' do
        subject
        expect(JSON.parse(response.body)).to eq([hash_for_template])
      end
    end
  end
end
