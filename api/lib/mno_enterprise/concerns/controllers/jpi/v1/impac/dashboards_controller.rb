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

  DASHBOARD_DEPENDENCIES = [:widgets, :'widgets.kpis', :kpis, :'kpis.alerts']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/dashboards
  def index
    dashboards

    # Fully qualify template path to allow concern to be included in different modules
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/index'
  end

  # GET /mnoe/jpi/v1/impac/dashboards/1
  #   -> GET /api/mnoe/v1/users/1/dashboards
  def show
    render_not_found('dashboard') unless dashboard(*DASHBOARD_DEPENDENCIES)

    # Fully qualify template path to allow concern to be included in different modules
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/show'
  end

  # POST /mnoe/jpi/v1/impac/dashboards
  #   -> POST /api/mnoe/v1/users/1/dashboards
  def create
    # TODO: enable authorization
    # authorize! :manage_dashboard, @dashboard
    dashboard = MnoEnterprise::Dashboard.new(dashboard_params)
    dashboard.relationships.owner = current_user
    dashboard.save!
    MnoEnterprise::EventLogger.info('dashboard_create', current_user.id, 'Dashboard Creation', dashboard)
    @dashboard = dashboard.load_required(*DASHBOARD_DEPENDENCIES)

    # Fully qualify template path to allow concern to be included in different modules
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/show'
  end

  # PUT /mnoe/jpi/v1/impac/dashboards/1
  #   -> PUT /api/mnoe/v1/dashboards/1
  def update
    return render_not_found('dashboard') unless dashboard

    # TODO: enable authorization
    # authorize! :manage_dashboard, dashboard
    dashboard.update_attributes!(dashboard_params)

    # Reload Dashboard
    @dashboard = dashboard.load_required(DASHBOARD_DEPENDENCIES)

    # Fully qualify template path to allow concern to be included in different modules
    render template: 'mno_enterprise/jpi/v1/impac/dashboards/show'
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
    render 'show'
  end

  private

    def dashboard(*included)
      @dashboard ||= MnoEnterprise::Dashboard.where(id: params[:id])
                                             .includes(included)
                                             .first
    end

    def dashboards
      @dashboards ||= MnoEnterprise::Dashboard.where(owner_id: current_user.id)
                                              .includes(*DASHBOARD_DEPENDENCIES)
    end

    def templates
      @templates ||= MnoEnterprise::Dashboard.templates
    end

    def template
      @template ||= MnoEnterprise::Dashboard.templates.find(params[:id]).first
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
end
