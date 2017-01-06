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

    if (@alert = current_user.alerts.create(kpi_alert.attributes))
      render 'show'
    else
      render_bad_request('attach alert to kpi', "impossible to save record: #{@kpi_alert.inspect}")
    end
  end

  # PUT /jpi/v1/impac/alerts/:id
  def update
    return render_bad_request('update alert attributes', 'no alert hash specified') unless params.require(:alert)
    return render_not_found('alert') unless alert

    attributes = params.require(:alert).permit(:title, :webhook, :sent)

    authorize! :manage_alert, alert

    if alert.update(attributes)
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

    def alert
      @alert ||= MnoEnterprise::Impac::Alert.find(params.require(:id))
    end

    def kpi_alert
      @alert ||= (
        kpi_id = params.require(:kpi_id)
        attributes = params.require(:alert).merge(impac_kpi_id: kpi_id)
        MnoEnterprise::Impac::Alert.new(attributes)
      )
    end
end
