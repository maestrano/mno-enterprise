module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::Impac::TenantDashboardsController
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
  # GET /mnoe/jpi/v1/admin/impac/tenant_dashboards
  def index
    dashboards
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/index'
  end

  # POST /mnoe/jpi/v1/admin/impac/tenant_dashboards
  #   -> POST /api/mnoe/v1/users/1/dashboards
  def create
    @dashboard = MnoEnterprise::Dashboard.create!(dashboard_create_params)
    MnoEnterprise::EventLogger.info('dashboard_create', tenant.id, 'Dashboard Creation', @dashboard)
    @dashboard = dashboard.load_required(*DASHBOARD_DEPENDENCIES)

    render_show
  end

  # PUT /mnoe/jpi/v1/admin/impac/tenant_dashboards/1
  #   -> PUT /api/mnoe/v1/dashboards/1
  def update
    return render_not_found('dashboard') unless dashboard
    dashboard.update_attributes!(dashboard_update_params)
    # Reload Dashboard
    @dashboard = dashboard.load_required(DASHBOARD_DEPENDENCIES)

    render_show
  end

  # DELETE /mnoe/jpi/v1/admin/impac/tenant_dashboards/1
  #   -> DELETE /api/mnoe/v1/dashboards/1
  def destroy
    return render_not_found('dashboard') unless dashboard
    MnoEnterprise::EventLogger.info('dashboard_delete', tenant.id, 'Dashboard Deletion', dashboard)
    dashboard.destroy!
    head status: :ok
  end

  private

  # TODO: would it make sense to have a tenant getter like this in the base resource ctrl?
  def tenant
    @tenant ||= MnoEnterprise::Tenant.show
  end

  def dashboard(*included)
    @dashboard ||= MnoEnterprise::Dashboard.where(owner_type: 'Mnoe::Tenant').includes(included).find(params[:id].to_i).first
  end

  def dashboards
    @dashboards ||= MnoEnterprise::Dashboard
      .includes(*DASHBOARD_DEPENDENCIES)
      .find(owner_type: 'Mnoe::Tenant')
  end

  def render_show
    render_not_found('dashboard') unless dashboard(*DASHBOARD_DEPENDENCIES)
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/show'
  end

  def whitelisted_params
    [:name, :currency, {widgets_order: []}, {organization_ids: []}]
  end

  # Allows all metadata attrs to be permitted, and maps it to :settings
  # for the Her "meta_data" issue.
  def dashboard_params
    params.require(:dashboard).permit(*whitelisted_params).tap do |whitelisted|
      whitelisted[:settings] = params[:dashboard][:metadata] || {}
    end
    .except(:metadata)
    .merge(owner_type: 'Mnoe::Tenant', owner_id: tenant.id)
  end
  alias :dashboard_update_params  :dashboard_params
  alias :dashboard_create_params  :dashboard_params
end
