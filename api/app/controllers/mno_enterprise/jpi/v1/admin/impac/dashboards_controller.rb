module MnoEnterprise
  # TODO: DRY with dashboard templates?
  class Jpi::V1::Admin::Impac::DashboardsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/impac/dashboards
    def index
      if params[:where]
        data_source = params[:where].delete(:data_sources)
        params[:where]['settings.like'] = "%#{data_source}%"
      end

      @dashboards = MnoEnterprise::Impac::Dashboard
      @dashboards = @dashboards.limit(params[:limit]) if params[:limit]
      @dashboards = @dashboards.skip(params[:offset]) if params[:offset]
      @dashboards = @dashboards.order_by(params[:order_by]) if params[:order_by]
      @dashboards = @dashboards.where(params[:where]) if params[:where]
      @dashboards = @dashboards.where(owner_type: 'User', owner_id: current_user.id)
      @dashboards = @dashboards.all.fetch

      response.headers['X-Total-Count'] = @dashboards.metadata[:pagination][:count]
    end

    # POST /mnoe/jpi/v1/admin/impac/dashboard
    def create
      @dashboard = MnoEnterprise::Impac::Dashboard.new(dashboard_params)

      # Abort on failure
      unless @dashboard.save
        return render json: { errors: dashboard.errors }, status: :bad_request
      end

      MnoEnterprise::EventLogger.info('dashboard_create', current_user.id, 'Dashboard Creation', @dashboard)
      render :show
    end

    # PATCH/PUT /mnoe/jpi/v1/admin/impac/dashboards/1
    def update
      return render json: { errors: { message: 'Dashboard not found' } }, status: :not_found unless dashboard

      # Abort on failure
      unless dashboard.update(dashboard_params)
        return render json: { errors: dashboard.errors }, status: :bad_request
      end

      MnoEnterprise::EventLogger.info('dashboard_update', current_user.id, 'Dashboard Update', dashboard)
      render :show
    end

    # DELETE /mnoe/jpi/v1/admin/impac/dashboards/1
    def destroy
      return render json: { errors: { message: 'Dashboard not found' } }, status: :not_found unless dashboard

      # Abort on failure
      unless dashboard.destroy
        return render json: { errors: 'Cannot destroy dashboard' }, status: :bad_request
      end

      MnoEnterprise::EventLogger.info('dashboard_delete', current_user.id, 'Dashboard Deletion', dashboard)
      head status: :ok
    end

    # Allows to create a dashboard using another dashboard as a source
    # At the moment, only dashboards of type "template" can be copied
    # Ultimately we could allow the creation of dashboards from any other dashboard
    # ---------------------------------
    # POST mnoe/jpi/v1/admin/impac/dashboards/1/copy
    def copy
      render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless template

      # Owner is the current user by default, can be overriden to something else (eg: current organization)
      @dashboard = template.copy(current_user, dashboard_params[:name], dashboard_params[:organization_ids])

      unless @dashboard.present?
        return render json: { errors: 'Cannot copy template' }, status: :bad_request
      end

      render :show
    end

    protected

    def dashboard
      @dashboard ||= MnoEnterprise::Impac::Dashboard.find(params[:id])
    end

    def template
      @template ||= MnoEnterprise::Impac::Dashboard.templates.find(params[:id])
    end

    def whitelisted_params
      [:name, :currency, { widgets_order: [] }, { organization_ids: [] }]
    end

    # Allows all metadata attrs to be permitted, and maps it to :settings
    # for the Her "meta_data" issue.
    def dashboard_params
      params.require(:dashboard).permit(*whitelisted_params).tap do |whitelisted|
        whitelisted[:settings] = params[:dashboard][:metadata] || {}
      end
      .except(:metadata)
      .merge(owner_type: 'User', owner_id: current_user.id)
    end
  end
end
