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

  DASHBOARD_DEPENDENCIES = [:widgets, :'widgets.kpis', :kpis, :'kpis.alerts', :'kpis.alerts.recipients']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/dashboards
  def index
    dashboards
    @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
  end

  # GET /mnoe/jpi/v1/impac/dashboards/1
  #   -> GET /api/mnoe/v1/users/1/dashboards
  def show
    @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
    render_not_found('dashboard') unless dashboard(*DASHBOARD_DEPENDENCIES)
  end

  # POST /mnoe/jpi/v1/impac/dashboards
  #   -> POST /api/mnoe/v1/users/1/dashboards
  def create
    # TODO: enable authorization
    # authorize! :manage_dashboard, @dashboard
    # if @dashboard.save
    @dashboard = MnoEnterprise::Dashboard.create!(dashboard_create_params)
    MnoEnterprise::EventLogger.info('dashboard_create', current_user.id, 'Dashboard Creation', @dashboard)
    @dashboard = dashboard.load_required(*DASHBOARD_DEPENDENCIES)
    @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
    render 'show'
  end

  # PUT /mnoe/jpi/v1/impac/dashboards/1
  #   -> PUT /api/mnoe/v1/dashboards/1
  def update
    return render_not_found('dashboard') unless dashboard

    # TODO: enable authorization
    # authorize! :manage_dashboard, dashboard
    dashboard.update_attributes!(dashboard_update_params)
    @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
    # Reload Dashboard
    @dashboard = dashboard.load_required(DASHBOARD_DEPENDENCIES)
    render 'show'
  end

  # DELETE /mnoe/jpi/v1/impac/dashboards/1
  #   -> DELETE /api/mnoe/v1/dashboards/1
  def destroy
    return render_not_found('dashboard') unless dashboard
    MnoEnterprise::EventLogger.info('dashboard_delete', current_user.id, 'Dashboard Deletion', dashboard)
    # TODO: enable authorization
    # authorize! :manage_dashboard, dashboard
    dashboard.destroy!
    head status: :ok
  end

  # Allows to create a dashboard using another dashboard as a source
  # At the moment, only dashboards of type "template" can be copied
  # Ultimately we could allow the creation of dashboards from any other dashboard
  # ---------------------------------
  # POST mnoe/jpi/v1/impac/dashboards/1/copy
  def copy
    return render_not_found('template') unless template
    # Owner is the current user by default, can be overriden to something else (eg: current organization)
    @dashboard = template.copy!(current_user, dashboard_params[:name], dashboard_params[:organization_ids])
    @dashboard = @dashboard.load_required(DASHBOARD_DEPENDENCIES)
    @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
    render 'show'
  end

  private

    def dashboard(*included)
      # TODO: [APIv2] Improve filtering by owner (owner_type?)
      @dashboard ||= MnoEnterprise::Dashboard.where(owner_id: current_user.id).includes(included).find(params[:id].to_i).first
    end

    def dashboards
      # TODO: [APIv2] Improve filtering by owner (owner_type?)
      @dashboards ||= MnoEnterprise::Dashboard.includes(*DASHBOARD_DEPENDENCIES).find(owner_id: current_user.id)
    end

    def templates
      @templates ||= MnoEnterprise::Dashboard.templates
    end

    def template
      @template ||= MnoEnterprise::Dashboard.templates.find(params[:id].to_i).first
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
      .merge(owner_type: "User", owner_id: current_user.id)
    end
    alias :dashboard_update_params  :dashboard_params
    alias :dashboard_create_params  :dashboard_params

end
