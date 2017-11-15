module MnoEnterprise
  class Jpi::V1::Admin::Impac::DashboardTemplatesController < Jpi::V1::Admin::BaseResourceController

    before_action :load_organizations, except: [:destroy]

    # TODO [APIV2]: [:'widgets.kpis', :'kpis.alerts']
    DASHBOARD_DEPENDENCIES = [:widgets, :kpis]

    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/admin/impac/dashboard_templates
    def index
      dashboard_templates = MnoEnterprise::Dashboard.templates.includes(*DASHBOARD_DEPENDENCIES)
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
      load_organizations
    end

    # GET /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def show
      @dashboard_template = MnoEnterprise::Dashboard.find_one!(params[:id], *DASHBOARD_DEPENDENCIES)
    end

    # POST /mnoe/jpi/v1/admin/impac/dashboard_templates
    def create
      @dashboard_template = MnoEnterprise::Dashboard.new(dashboard_template_params.merge(dashboard_type: 'template'))
      @dashboard_template.save!
      MnoEnterprise::EventLogger.info('dashboard_template_create', current_user.id, 'Dashboard Template Creation', @dashboard_template)
      @dashboard_template = @dashboard_template.load_required(*DASHBOARD_DEPENDENCIES)
      render 'show'
    end

    # PATCH/PUT /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def update
      @dashboard_template = MnoEnterprise::Dashboard.find_one!(params[:id])
      dashboard_template.update!(dashboard_template_params)
      @dashboard_template = @dashboard_template.load_required(*DASHBOARD_DEPENDENCIES)
      MnoEnterprise::EventLogger.info('dashboard_template_update', current_user.id, 'Dashboard Template Update', @dashboard_template)
      render 'show'
    end

    # DELETE /mnoe/jpi/v1/admin/impac/dashboard_templates/1
    def destroy
      @dashboard_template = MnoEnterprise::Dashboard.find_one!(params[:id])
      MnoEnterprise::EventLogger.info('dashboard_template_delete', current_user.id, 'Dashboard Template Deletion', @dashboard_template)
      @dashboard_template.destroy!
      head status: :ok
    end

    private

    def load_organizations
      @organizations = MnoEnterprise::Organization.where('users.id': current_user.id)
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

