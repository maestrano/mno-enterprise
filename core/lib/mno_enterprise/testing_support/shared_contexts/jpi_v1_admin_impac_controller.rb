module MnoEnterprise::TestingSupport::SharedContexts::JpiV1AdminImpacController
  def hash_for_kpi(kpi)
    {
      "id" => kpi.id,
      "element_watched" => kpi.element_watched,
      "endpoint" => kpi.endpoint
    }
  end

  shared_context 'MnoEnterprise::Jpi::V1::Admin::Impac' do
    shared_context "#{described_class}: dashboard dependencies stubs" do
      before do
        # Not ideal but this is a nested context
        if described_class == MnoEnterprise::Jpi::V1::Admin::Impac::DashboardsController
          api_stub_for(
            get: "/organizations?filter[uid.in][]=#{org.uid}",
            response: from_api([org])
          )
        end
        if described_class == MnoEnterprise::Jpi::V1::Admin::Impac::DashboardTemplatesController
          api_stub_for(
            get: "/users/#{user.id}/organizations",
            response: from_api([org])
          )
        end
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
      end
    end

    let(:user) { build(:user, :admin, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:dashboard) { build(:impac_dashboard, dashboard_type: 'dashboard', organization_ids: [org.uid], currency: 'EUR', settings: metadata) }
    let(:widget) { build(:impac_widget, dashboard: dashboard, owner: user) }
    let(:d_kpi) { build(:impac_kpi, dashboard: dashboard) }
    let(:w_kpi) { build(:impac_kpi, widget: widget) }

    let(:hash_for_widget) do
      {
        "id" => widget.id,
        "name" => widget.name,
        "endpoint" => widget.widget_category,
        "width" => widget.width,
        "kpis" => [hash_for_kpi(w_kpi)]
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
  end
end


