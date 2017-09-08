module MnoEnterprise
  class Jpi::V1::Admin::Impac::DashboardTemplatesController < Jpi::V1::Admin::BaseResourceController

    # TODO [APIV2]: [:'widgets.kpis', :'kpis.alerts']
    DASHBOARD_DEPENDENCIES = [:widgets, :kpis]

    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/admin/impac/dashboard_templates
    def index
      if params[:terms]
        # For search mode
        @dashboard_templates = []
        JSON.parse(params[:terms]).map { |t| @dashboard_templates = @dashboard_templates | dashboard_templates.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @dashboards_templates.count
      else
        query = MnoEnterprise::Dashboard.apply_query_params(params, dashboard_templates)
        @dashboard_templates = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def show
      render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless dashboard_template.present?
    end

    # POST /mnoe/jpi/v1/admin/impac/dashboard_templates
    def create
      @dashboard_template = MnoEnterprise::Dashboard.new(dashboard_template_params.merge(dashboard_type: 'template'))

      # Abort on failure
      unless @dashboard_template.save
        return render json: { errors: dashboard_template.errors }, status: :bad_request
      end

      MnoEnterprise::EventLogger.info('dashboard_template_create', current_user.id, 'Dashboard Template Creation', dashboard_template)
      render 'show'
    end

    # PATCH/PUT /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def update
      return render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless dashboard_template

      # Abort on failure
      unless dashboard_template.update(dashboard_template_params)
        return render json: { errors: dashboard_template.errors }, status: :bad_request
      end

      MnoEnterprise::EventLogger.info('dashboard_template_update', current_user.id, 'Dashboard Template Update', dashboard_template)
      render 'show'
    end

    # DELETE /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def destroy
      return render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless dashboard_template

      MnoEnterprise::EventLogger.info('dashboard_template_delete', current_user.id, 'Dashboard Template Deletion', dashboard_template)

      # Abort on failure
      unless dashboard_template.destroy
        return render json: { errors: 'Cannot destroy dashboard template' }, status: :bad_request
      end

      head status: :ok
    end

    private

    def dashboard_templates
      @dashboard_templates ||= MnoEnterprise::Dashboard.templates.includes(*DASHBOARD_DEPENDENCIES)
    end

    def dashboard_template
      @dashboard_template ||= dashboard_templates.find(params[:id].to_i).first
    end

    def whitelisted_params
      [:name, :currency, { widgets_order: [] }, { organization_ids: [] }, :published]
    end

    # Allows all metadata attrs to be permitted, and maps it to :settings
    # for the Her "meta_data" issue.
    def dashboard_template_params
      params.require(:dashboard).permit(*whitelisted_params).tap do |whitelisted|
        whitelisted[:settings] = params[:dashboard][:metadata] || {}
      end
      .except(:metadata)
    end
  end
end

