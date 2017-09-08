module MnoEnterprise
  # From the Admin panel, an admin can create/update/delete kpis to/from a dashboard template
  class Jpi::V1::Admin::Impac::KpisController < Jpi::V1::Admin::BaseResourceController
    before_filter :find_valid_kpi, only: [:update, :delete]

    # POST /mnoe/jpi/v1/admin/impac/dashboard_templates/:id/kpis
    def create
      return render json: { errors: { message: 'Dashboard template not found' } }, status: :not_found unless template.present?

      @kpi = MnoEnterprise::Kpi.create(kpi_create_params)
      return render json: { errors: (@kpi && @kpi.errors).to_a }, status: :bad_request unless @kpi.present? && @kpi.valid?

      MnoEnterprise::EventLogger.info('kpi_create', current_user.id, 'Template KPI Creation', @kpi)
      @no_content = true
      render 'show'
    end

    # PUT /mnoe/jpi/v1/admin/impac/kpis/:id
    def update
      unless kpi.present? && kpi.update(kpi_update_params)
        msg = kpi.errors.full_messages.join(', ') || 'unable to update KPI.'
        return render_bad_request("update kpi (id=#{kpi.id})", msg)
      end

      MnoEnterprise::EventLogger.info('kpi_update', current_user.id, 'Template KPI Update', kpi)
      @nocontent = !params['metadata']
      render 'show'
    end

    # DELETE /mnoe/jpi/v1/admin/impac/kpis/:id
    def destroy
      return render_not_found('kpi') unless kpi.present?

      MnoEnterprise::EventLogger.info('kpi_delete', current_user.id, 'Template KPI Deletion', kpi)

      unless kpi.destroy
        msg = kpi.errors.full_messages.join(', ') || 'unable to update KPI.'
        return render_bad_request("delete kpi (id=#{kpi.id})", msg)
      end
      head status: :ok
    end

    private

    def template
      MnoEnterprise::Dashboard.templates.find(params[:dashboard_template_id].to_i).first
    end

    def kpi
      @kpi ||= MnoEnterprise::Kpi.find_one(params[:id].to_i)
    end

    def kpi_create_params
      whitelist = [:dashboard_id, :widget_id, :endpoint, :source, :element_watched, { extra_watchables: [] }]
      create_params = extract_params(whitelist)
      if create_params[:widget_id]
        create_params
      else
        create_params.merge(dashboard_id: template.id)
      end
    end

    def kpi_update_params
      whitelist = [:element_watched, {extra_watchables: []}]
      extract_params(whitelist)
    end

    def extract_params(whitelist)
      (p = params).require(:kpi).permit(*whitelist).tap do |whitelisted|
        whitelisted[:settings] = p[:kpi][:metadata] || {}
        # TODO: strong params for targets & extra_params attributes (keys will depend on the kpi).
        whitelisted[:targets] = p[:kpi][:targets] if p[:kpi][:targets].present?
        whitelisted[:extra_params] = p[:kpi][:extra_params] if p[:kpi][:extra_params].present?
      end
      .except(:metadata)
    end

    alias :find_valid_kpi  :kpi
  end
end
