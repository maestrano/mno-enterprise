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
    @alerts = MnoEnterprise::Alert.includes(:recipients).where('recipient.id' => current_user.id)
  end

  # POST /jpi/v1/impac/kpis/:kpi_id/alerts
  def create
    return render_bad_request('attach alert to kpi', 'no alert specified') unless params.require(:alert)
    return render_not_found('kpi') unless MnoEnterprise::Kpi.find_one(params.require(:kpi_id))

    # TODO: Manage authorization
    #authorize! :manage_alert, kpi_alert
    @alert = MnoEnterprise::Alert.create!(alert_params)
    @alert.update_recipients!([current_user.id])
    @alert = @alert.load_required(:recipients)
    render 'show'
  end

  # PUT /jpi/v1/impac/alerts/:id
  def update
    return render_bad_request('update alert attributes', 'no alert hash specified') unless params.require(:alert)
    return render_not_found('alert') unless alert

    attributes = params.require(:alert).permit(:title, :webhook, :sent)

    # TODO: Manage authorization
    # authorize! :manage_alert, alert
    alert.update_attributes!(attributes)
    render 'show'
  end

  # DELETE /jpi/v1/impac/alerts/:id
  def destroy
    return render_not_found('alert') unless alert

    # TODO: Manage authorization
    # authorize! :manage_alert, alert
    service = alert.service
    alert.destroy!
    render json: { deleted: { service: service } }
  end

  private

    def alert
      @alert ||= MnoEnterprise::Alert.find_one(params.require(:id))
    end

    def alert_params
      params.require(:alert).merge(kpi_id: params.require(:kpi_id))
    end
end
