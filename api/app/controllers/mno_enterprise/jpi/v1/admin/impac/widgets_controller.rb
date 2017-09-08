module MnoEnterprise
  # From the Admin panel, an admin can:
  # - add widgets to template dashboards (passing the dashboard template id)
  # - update any widget (passing its id)
  # - delete any widget (passing its id)
  class Jpi::V1::Admin::Impac::WidgetsController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/impac/dashboard_templates/:id/widgets
    def create
      return render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless template.present?

      @widget = MnoEnterprise::Widget.create(widget_create_params)
      return render json: { errors: (widget && widget.errors).to_a }, status: :bad_request unless widget.present? && widget.valid?

      MnoEnterprise::EventLogger.info('widget_create', current_user.id, 'Template Widget Creation', widget)
      @no_content = true
      render 'show'
    end

    # PUT /mnoe/jpi/v1/admin/impac/widgets/:id
    def update
      unless widget.present? && widget.update(widget_update_params)
        return render json: { errors: 'Cannot update widget' }, status: :bad_request
      end

      MnoEnterprise::EventLogger.info('widget_update', current_user.id, 'Template Widget Update', widget)
      @nocontent = !params['metadata']
      render 'show'
    end

    # DELETE /mnoe/jpi/v1/admin/impac/widgets/:id
    def destroy
      return render_not_found('widget') unless widget.present?

      MnoEnterprise::EventLogger.info('widget_delete', current_user.id, 'Template Widget Deletion', widget)

      unless widget.destroy
        msg = widget.errors.full_messages.join(', ') || 'unable to update Widget.'
        return render_bad_request("delete widget (id=#{widget.id})", msg)
      end

      head status: :ok
    end

    private

    def template
      MnoEnterprise::Dashboard.templates.find(params[:dashboard_template_id].to_i).first
    end

    def widget
      @widget ||= MnoEnterprise::Widget.find(params[:id].to_i).first
    end

    def widget_create_params
      params.require(:widget).permit(:endpoint, :name, :width).tap do |whitelisted|
        whitelisted[:settings] = params[:widget][:metadata] || {}
        # TODO: remove when all deployed versions of Impac! Angular will be above v1.5.0
        # When this is done:
        # - :widget_category can definitively be renamed to :endpoint in mnohub and mnoe
        # - the widget templates can be completely removed from mnohub and mnoe
        whitelisted[:widget_category] = params[:widget][:endpoint]
      end
      .except(:metadata)
      .merge(dashboard_id: template.id)
    end

    def widget_update_params
      params.require(:widget).permit(:name, :width).tap do |whitelisted|
        whitelisted[:settings] = params[:widget][:metadata] || {}
      end
      .except(:metadata)
    end
  end
end
