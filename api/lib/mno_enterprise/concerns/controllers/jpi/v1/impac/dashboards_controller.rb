module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::DashboardsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/dashboards
  def index
    dashboards
  end

  # GET /mnoe/jpi/v1/impac/dashboards/1
  #   -> GET /api/mnoe/v1/users/1/dashboards
  def show
    dashboard
    render_not_found('dashboard') unless @dashboard
  end

  # POST /mnoe/jpi/v1/impac/dashboards
  #   -> POST /api/mnoe/v1/users/1/dashboards
  def create
    if @dashboard = dashboards.create(dashboard_create_params)
      # authorize! :create, @dashboard
      MnoEnterprise::EventLogger.info('dashboard_create', current_user.id, 'Dashboard Creation', nil, @dashboard)
      render 'show'
    else
      render_bad_request('create dashboard', @dashboard.errors)
    end
  end

  # PUT /mnoe/jpi/v1/impac/dashboards/1
  #   -> PUT /api/mnoe/v1/dashboards/1
  def update
    return render_not_found('dashboard') unless dashboard

    if dashboard.update(dashboard_update_params)
      # authorize! :update, dashboard
      render 'show'
    else
      render_bad_request('update dashboard', dashboard.errors)
    end
  end

  # DELETE /mnoe/jpi/v1/impac/dashboards/1
  #   -> DELETE /api/mnoe/v1/dashboards/1
  def destroy
    return render_not_found('dashboard') unless dashboard

    if dashboard.destroy
      # authorize! :destroy, @dashboard
      MnoEnterprise::EventLogger.info('dashboard_delete', current_user.id, 'Dashboard Deletion', nil, dashboard)
      head status: :ok
    else
      render_bad_request('destroy dashboard', 'Unable to destroy dashboard')
    end
  end

  protected

  def dashboard
    @dashboard ||= current_user.dashboards.to_a.find { |d| d.id.to_s == params[:id].to_s }
  end

  def dashboards
    @dashboards ||= current_user.dashboards
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
  end
  alias :dashboard_update_params  :dashboard_params
  alias :dashboard_create_params  :dashboard_params
end
