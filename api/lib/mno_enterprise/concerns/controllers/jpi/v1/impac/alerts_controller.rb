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
    u = current_user.load_required(:alerts)
    @alerts = u.alerts
  end

  # POST /jpi/v1/impac/kpis/:kpi_id/alerts
  def create
    return render_bad_request('attach alert to kpi', 'no alert specified') unless params.require(:alert)
    return render_not_found('kpi') unless MnoEnterprise::Kpi.find_one(params.require(:kpi_id))

    # TODO: Manage authorization
    #authorize! :manage_alert, kpi_alert

    @alert = MnoEnterprise::Alert.create(alert_params.merge(recipient_ids: [current_user.id]))
    if @alert.errors.empty?
      render 'show'
    else
      render_bad_request('attach alert to kpi', @alert.errors)
    end
  end

  # PUT /jpi/v1/impac/alerts/:id
  def update
    return render_bad_request('update alert attributes', 'no alert hash specified') unless params.require(:alert)
    return render_not_found('alert') unless alert

    attributes = params.require(:alert).permit(:title, :webhook, :sent)

    # TODO: Manage authorization
    # authorize! :manage_alert, alert

    if alert.update_attributes(attributes)
      render 'show'
    else
      render_bad_request('update alert', alert.errors)
    end
  end

  # DELETE /jpi/v1/impac/alerts/:id
  def destroy
    return render_not_found('alert') unless alert

    # TODO: Manage authorization
    # authorize! :manage_alert, alert

    service = alert.service
    if alert.destroy
      render json: { deleted: { service: service } }
    else
      render_bad_request('destroy alert', "impossible to destroy record: #{alert.errors}")
    end
  end


  private

    def alert
      @alert ||= MnoEnterprise::Alert.find_one(params.require(:id))
    end

    def alert_params
      params.require(:alert).merge(kpi_id: params.require(:kpi_id))
    end
end
