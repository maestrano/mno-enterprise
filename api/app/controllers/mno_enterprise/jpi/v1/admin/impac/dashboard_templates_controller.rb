module MnoEnterprise
  class Jpi::V1::Admin::Impac::DashboardTemplatesController < Jpi::V1::Admin::BaseResourceController

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
        @dashboard_templates = dashboard_templates
        @dashboard_templates = @dashboard_templates.limit(params[:limit]) if params[:limit]
        @dashboard_templates = @dashboard_templates.skip(params[:offset]) if params[:offset]
        @dashboard_templates = @dashboard_templates.order_by(params[:order_by]) if params[:order_by]
        @dashboard_templates = @dashboard_templates.where(params[:where]) if params[:where]
        @dashboard_templates = @dashboard_templates.all.fetch
        response.headers['X-Total-Count'] = @dashboard_templates.metadata[:pagination][:count]
      end
    end

    # GET /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def show
      render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless dashboard_template.present?
    end

    # POST /mnoe/jpi/v1/admin/impac/dashboard_templates
    def create
      @dashboard_template = dashboard_templates.create(dashboard_template_params.merge(dashboard_type: 'template'))
      return render json: { errors: dashboard_template.errors }, status: :bad_request unless dashboard_template.valid?
        
      MnoEnterprise::EventLogger.info('dashboard_template_create', current_user.id, 'Dashboard Template Creation', dashboard_template)
      render 'show'
    end

    # PATCH/PUT /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def update
      return render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless dashboard_template

      dashboard_template.update(dashboard_template_params)
      return render json: { errors: dashboard_template.errors }, status: :bad_request unless dashboard_template.valid?

      MnoEnterprise::EventLogger.info('dashboard_template_update', current_user.id, 'Dashboard Template Update', dashboard_template)
      render 'show'
    end

    # DELETE /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def destroy
      return render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless dashboard_template

      return render json: { errors: 'Cannot destroy dashboard template' }, status: :bad_request unless dashboard_template.destroy

      MnoEnterprise::EventLogger.info('dashboard_template_delete', current_user.id, 'Dashboard Template Deletion', dashboard_template)
      head status: :ok
    end

    private

    def dashboard_templates
      @dashboard_templates ||= MnoEnterprise::Impac::Dashboard.templates
    end

    def dashboard_template
      @dashboard_template ||= dashboard_templates.find(params[:id].to_i)
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

