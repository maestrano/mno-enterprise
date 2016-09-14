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
  def show
    dashboard
    render json: { errors: "Dashboard id #{params[:id]} doesn't exist" }, status: :not_found unless @dashboard
  end

  # POST /mnoe/jpi/v1/impac/dashboards
  #  -> POST /api/mnoe/v1/users/282/dashboards
  def create
    if @dashboard = dashboards.create(dashboard_create_params)
      # authorize! :create, @dashboard
      MnoEnterprise::EventLogger.info('dashboard_create', current_user.id, 'Dashboard Creation', nil, @dashboard)
      render 'show'
    else
      render json: @dashboard.errors, status: :bad_request
    end
  end

  # PUT /mnoe/jpi/v1/impac/dashboards/1
  def update
    if dashboard.update(dashboard_update_params)
      # dashboard.assign_attributes(attrs)
      # authorize! :update, dashboard
      render 'show'
    else
      render json: @dashboard.errors, status: :bad_request
    end
  end

  # DELETE /mnoe/jpi/v1/impac/dashboards/1
  def destroy
    # authorize! :destroy, @dashboard
    if dashboard.destroy
      MnoEnterprise::EventLogger.info('dashboard_delete', current_user.id, 'Dashboard Deletion', nil, dashboard)
      head status: :ok
    else
      render json: 'Unable to destroy dashboard', status: :bad_request
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
      whitelisted[:settings] = params[:dashboard][:metadata]
    end
    .except(:metadata)
  end
  alias :dashboard_update_params  :dashboard_params
  alias :dashboard_create_params  :dashboard_params
end
