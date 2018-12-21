module MnoEnterprise
  # TODO: DRY with dashboard templates?
  class Jpi::V1::Admin::Impac::DashboardsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/impac/dashboards
    # TODO: filter by org Id in mnoe
    # TODO: should filter to current_user?
    # TODO: what happen when more than 30 dhb? => custom scope in MnoHub? with LIKE text search
    def index
      # query = MnoEnterprise::Impac::Dashboard
      #           .apply_query_params(params)
      #           # .includes(*DASHBOARD_DEPENDENCIES)
      #
      # response.headers['X-Total-Count'] = query.meta.record_count
      #
      # @dashboards = query.to_a

      data_source = params[:where].delete(:data_sources) if params[:where]

      @dashboards = MnoEnterprise::Impac::Dashboard
      @dashboards = @dashboards.limit(params[:limit]) if params[:limit]
      @dashboards = @dashboards.skip(params[:offset]) if params[:offset]
      @dashboards = @dashboards.order_by(params[:order_by]) if params[:order_by]
      @dashboards = @dashboards.where(params[:where]) if params[:where]
      @dashboards = @dashboards.all.fetch

      response.headers['X-Total-Count'] = @dashboards.metadata[:pagination][:count]

      if data_source
        @dashboards = @dashboards.select { |dhb| dhb.organizations.map(&:id).include?(data_source.to_i) }
      end

      # @dashboards = current_user.dashboards
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

    protected

    def dashboard
      @dashboard ||= MnoEnterprise::Impac::Dashboard.find(params[:id])
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
