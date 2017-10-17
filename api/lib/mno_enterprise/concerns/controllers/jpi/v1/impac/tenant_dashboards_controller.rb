module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::TenantDashboardsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  DASHBOARD_DEPENDENCIES = [:widgets, :'widgets.kpis', :kpis, :'kpis.alerts', :'kpis.alerts.recipients']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/tenant_dashboards
  def index
    dashboards
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/index'
  end

  private

  def dashboards
    @dashboards ||= MnoEnterprise::Dashboard
      .includes(*DASHBOARD_DEPENDENCIES)
      .find(owner_type: 'Mnoe::Tenant')
  end
end
