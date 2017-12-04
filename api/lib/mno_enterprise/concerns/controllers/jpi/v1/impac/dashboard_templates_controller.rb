module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::DashboardTemplatesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    DASHBOARD_DEPENDENCIES = [:widgets, :'widgets.kpis', :kpis, :'kpis.alerts']
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/dashboard_templates
  def index
    @templates = MnoEnterprise::Dashboard.published_templates.includes(*DASHBOARD_DEPENDENCIES)
    @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
  end
end
