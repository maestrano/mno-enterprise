module MnoEnterprise
  class Jpi::V1::Admin::DashboardTemplatesController < Jpi::V1::Admin::BaseResourceController

    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/admin/dashboard_templates
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

    # GET /mnoe/jpi/v1/admin/dashboard_templates/1
    def show
      dashboard_template
      render_not_found('dashboard template') unless @dashboard_template
    end

    # POST /mnoe/jpi/v1/admin/dashboard_templates
    def create
      if @dashboard_template = dashboard_templates.create(dashboard_template_params.merge(dashboard_type: 'template'))
        MnoEnterprise::EventLogger.info('dashboard_template_create', current_user.id, 'Dashboard Template Creation', @dashboard_template)
        render 'show'
      else
        render_bad_request('create dashboard template', @dashboard_template.errors)
      end
    end

    # PATCH /mnoe/jpi/v1/admin/dashboard_templates/1
    def update
      return render_not_found('dashboard template') unless dashboard_template

      if dashboard_template.update(dashboard_template_params)
        render 'show'
      else
        render_bad_request('update dashboard template', dashboard_template.errors)
      end
    end

    # DELETE /mnoe/jpi/v1/admin/dashboard_templates/1
    def destroy
      return render_not_found('dashboard template') unless dashboard_template

      if dashboard_template.destroy
        MnoEnterprise::EventLogger.info('dashboard_template_delete', current_user.id, 'Dashboard Template Deletion', dashboard_template)
        head status: :ok
      else
        render_bad_request('destroy dashboard template', 'Unable to destroy dashboard template')
      end
    end

    private

    def dashboard_templates
      @dashboard_templates ||= MnoEnterprise::Impac::Dashboard.templates
    end

    def dashboard_template
      @dashboard_template ||= MnoEnterprise::Impac::Dashboard.find(params[:id].to_i)
    end

    def whitelisted_params
      [:name, :currency, {widgets_order: []}, {organization_ids: []}]
    end

    # Allows all metadata attrs to be permitted, and maps it to :settings
    # for the Her "meta_data" issue.
    def dashboard_template_params
      params.require(:dashboard_template).permit(*whitelisted_params).tap do |whitelisted|
        whitelisted[:settings] = params[:dashboard_template][:metadata] || {}
      end
      .except(:metadata)
    end
  end
end

