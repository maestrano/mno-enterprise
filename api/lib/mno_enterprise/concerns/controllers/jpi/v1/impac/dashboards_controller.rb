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
    # TODO: dashboards.build breaks as dashboard.organization_ids returns nil, instead of an
    #       empty array. (see MnoEnterprise::Impac::Dashboard #organizations)
    # @dashboard = dashboards.build(dashboard_create_params)
    # TODO: enable authorization
    # authorize! :manage_dashboard, @dashboard
    # if @dashboard.save
    if @dashboard = dashboards.create(dashboard_create_params)
      MnoEnterprise::EventLogger.info('dashboard_create', current_user.id, 'Dashboard Creation', @dashboard)

      render 'show'
    else
      render_bad_request('create dashboard', @dashboard.errors)
    end
  end

  # PUT /mnoe/jpi/v1/impac/dashboards/1
  #   -> PUT /api/mnoe/v1/dashboards/1
  def update
    return render_not_found('dashboard') unless dashboard

    # TODO: enable authorization
    # authorize! :manage_dashboard, dashboard

    if dashboard.update(dashboard_update_params)
      render 'show'
    else
      render_bad_request('update dashboard', dashboard.errors)
    end
  end

  # DELETE /mnoe/jpi/v1/impac/dashboards/1
  #   -> DELETE /api/mnoe/v1/dashboards/1
  def destroy
    return render_not_found('dashboard') unless dashboard

    # TODO: enable authorization
    # authorize! :manage_dashboard, dashboard

    if dashboard.destroy
      MnoEnterprise::EventLogger.info('dashboard_delete', current_user.id, 'Dashboard Deletion', dashboard)
      head status: :ok
    else
      render_bad_request('destroy dashboard', 'Unable to destroy dashboard')
    end
  end

  # Allows to create a dashboard using another dashboard as a source
  # At the moment, only dashboards of type "template" can be copied
  # Ultimately we could allow the creation of dashboards from any other dashboard
  # ---------------------------------
  # POST mnoe/jpi/v1/impac/dashboards/1/copy
  def copy
    return render_not_found('template') unless template

    # Owner is the current user by default, can be overriden to something else (eg: current organization)
    @dashboard = template.copy(current_user, dashboard_params[:name], dashboard_params[:organization_ids])
    return render_bad_request('copy template', 'Unable to copy template') unless dashboard.present?

    render 'show'
  end

  private

    def dashboards
      @dashboards ||= current_user.dashboards
    end

    def dashboard
      @dashboard ||= current_user.dashboards.find(params[:id].to_i)
    end

    def templates
      @templates ||= MnoEnterprise::Impac::Dashboard.templates
    end

    def template
      @template ||= templates.find(params[:id].to_i)
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
