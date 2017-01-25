module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::AlertsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  # GET /jpi/v1/impac/alerts
  def index
    @alerts = current_user.alerts
  end

  # POST /jpi/v1/impac/kpis/:kpi_id/alerts
  def create
    return render_bad_request('attach alert to kpi', 'no alert specified') unless params.require(:alert)
    return render_not_found('kpi') unless kpi_alert.kpi

    authorize! :manage_alert, kpi_alert

    if (@alert = kpi_alert.save(kpi_alert.attributes))
      render 'show'
    else
      render_bad_request('attach alert to kpi', "impossible to save record: #{kpi_alert.inspect}")
    end
  end

  # PUT /jpi/v1/impac/alerts/:id
  def update
    return render_bad_request('update alert attributes', 'no alert hash specified') unless params.require(:alert)
    return render_not_found('alert') unless alert

    authorize! :manage_alert, alert

    if alert.update(kpi_update_params)
      render 'show'
    else
      render_bad_request('update alert', "unable to save record: #{alert.inspect}")
    end
  end

  # DELETE /jpi/v1/impac/alerts/:id
  def destroy
    return render_not_found('alert') unless alert

    authorize! :manage_alert, alert

    service = alert.service
    if alert.destroy
      render json: { deleted: { service: service } }
    else
      render_bad_request('destroy alert', "impossible to destroy record: #{alert.inspect}")
    end
  end


  private

    def kpi_create_params
      params.require(:alert).permit(:title, :webhook, :service, recipient_ids: [])
    end

    def kpi_update_params
      params.require(:alert).permit(:title, :webhook, :sent, recipient_ids: [])
    end

    def alert
      @alert ||= MnoEnterprise::Impac::Alert.find(params.require(:id))
    end

    def valid_kpi_alert_attrs
      kpi_id = params.require(:kpi_id)
      attributes = kpi_create_params.merge(impac_kpi_id: kpi_id)
      attributes[:recipient_ids] = [current_user.id] unless attributes.has_key?(:recipient_ids)
      attributes
    end

    def kpi_alert
      @alert ||= MnoEnterprise::Impac::Alert.new(valid_kpi_alert_attrs)
    end
end
