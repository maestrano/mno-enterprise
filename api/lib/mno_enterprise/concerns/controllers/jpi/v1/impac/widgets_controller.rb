module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::WidgetsController
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
  # GET /mnoe/jpi/v1/impac/organizations/:organization_id/widgets
  #  -> GET /api/mnoe/v1/organizations/:id/widgets
  def index
    render_not_found('organization') unless parent_organization
    @widgets = MnoEnterprise::Widget.find(organization_id: parent_organization.id)
  end

  # POST /mnoe/jpi/v1/impac/dashboards/:id/widgets
  #  -> POST /api/mnoe/v1/dashboards/:id/widgets
  def create
    @widget = MnoEnterprise::Widget.create!(widget_create_params)
    MnoEnterprise::EventLogger.info('widget_create', current_user.id, 'Widget Creation', @widget)
    @nocontent = true # no data fetch from Connec!
    render 'show'
  end

  # PUT /mnoe/jpi/v1/impac/widgets/:id
  #   -> PUT /api/mnoe/v1/widgets/:id
  def update
    return render_not_found('widget') unless widget
    widget.update_attributes!(widget_update_params)
    MnoEnterprise::EventLogger.info('widget_update', current_user.id, 'Widget Update', widget, {widget_action: params[:widget]})
    @nocontent = !params['metadata']
    render 'show'

  end

  # DELETE /mnoe/jpi/v1/impac/widgets/:id
  #   -> DELETE /api/mnoe/v1/widgets/:id
  def destroy
    return render_not_found('widget') unless widget
    MnoEnterprise::EventLogger.info('widget_delete', current_user.id, 'Widget Deletion', widget)
    widget.destroy!
    head status: :ok
  end

  #=================================================
  # Private methods
  #=================================================
  private

    def widget
      @widget ||= MnoEnterprise::Widget.find(params[:id]).first
    end

    def widgets
      @widgets ||= MnoEnterprise::Widget.find(dashboard_id: params[:dashboard_id])
    end

    def widget_create_params
      params.require(:widget).permit(:endpoint, :name, :width).tap do |whitelisted|
        whitelisted[:settings] = params[:widget][:metadata] || {}
        # TODO: remove when mnohub migrated to new model
        whitelisted[:widget_category] = params[:widget][:endpoint]
      end
      .except(:metadata)
      .merge(dashboard_id: params[:dashboard_id])
    end

    def widget_update_params
      params.require(:widget).permit(:name, :width).tap do |whitelisted|
        whitelisted[:settings] = params[:widget][:metadata] || {}
      end
      .except(:metadata)
    end
end
