module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::KpisController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json

    before_filter :find_valid_kpi, only: [:update, :delete]
    before_filter :require_feature_enabled
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/kpis
  # This action is used as a sort of 'proxy' for retrieving KPI templates which are
  # usually retrieved from Impac! API, and customising the attributes.
  def index
    # Retrieve kpis templates from impac api.
    # TODO: improve request params to work for strong parameters
    attrs = params.slice('metadata')
    auth = { username: MnoEnterprise.tenant_id, password: MnoEnterprise.tenant_key }

    response = begin
      MnoEnterprise::ImpacClient.send_get('/api/v2/kpis', attrs, basic_auth: auth)
    rescue => e
      return render json: { message: "Unable to retrieve kpis from Impac API | Error #{e}" }
    end

    # customise available kpis
    kpis = (response['kpis'] || []).map do |kpi|
      kpi = kpi.with_indifferent_access
      kpi[:watchables].map do |watchable|
        kpi.merge(
          name: "#{kpi[:name]} #{watchable.capitalize unless kpi[:name].downcase.index(watchable)}".strip,
          watchables: [watchable],
          target_placeholders: {watchable => kpi[:target_placeholders][watchable]},
        )
      end
    end
    .flatten

    render json: { kpis: kpis }
  end

  # POST /mnoe/jpi/v1/impac/dashboards/:dashboard_id/kpis
  #   -> POST /api/mnoe/v1/dashboards/:id/kpis
  #   -> POST /api/mnoe/v1/users/:id/alerts
  def create
    # TODO: ability for managing widget.
    authorize! :manage_dashboard, dashboard
    # TODO: attach widget onto KPI capability.
    # authorize! :manage_widget, widget if widget

    # TODO: nest alert in as a param, with the current user as a recipient.
    if @kpi = kpi_parent.kpis.create(kpi_create_params)
      # Creates a default alert for kpis created with targets defined.
      if kpi.targets.present?
        current_user.alerts.create({service: 'inapp', impac_kpi_id: kpi.id})
        # TODO: reload is adding the recipients to the kpi alerts (making another request).
        kpi.reload
      end
      render 'show'
    else
      msg = kpi.errors.full_messages.join(', ') || 'unable to create KPI.'
      render_bad_request("create kpi (id=#{kpi.id})", msg)
    end
  end

  # PUT /mnoe/jpi/v1/impac/kpis/:id
  #   -> PUT /api/mnoe/v1/kpis/:id
  def update
    authorize! :manage_kpi, kpi

    params = kpi_update_params

    # TODO: refactor into models
    # --
    # Creates an in-app alert if target is set for the first time (in-app alerts should be activated by default)
    if kpi.targets.blank? && params[:targets].present?
      current_user.alerts.create({service: 'inapp', impac_kpi_id: kpi.id})

    # If targets have changed, reset all the alerts 'sent' status to false.
    elsif kpi.targets && params[:targets].present? && params[:targets] != kpi.targets
      kpi.alerts.each { |alert| alert.update(sent: false) }

    # Removes all the alerts if the targets are removed
    elsif params[:targets].blank?
      kpi.alerts.each(&:destroy)
    end

    if kpi.update(kpi_update_params)
      render 'show'
    else
      msg = @kpi.errors.full_messages.join(', ') || 'unable to update KPI.'
      render_bad_request("update kpi (id=#{kpi.id})", msg)
    end
  end

  # DELETE /mnoe/jpi/v1/impac/kpis/:id
  #   -> DELETE /api/mnoe/v1/kpis/:id
  def destroy
    authorize! :manage_kpi, kpi

    if kpi.destroy
      head status: :ok
    else
      render_bad_request('destroy kpi', "impossible to destroy kpi (id=#{kpi.id})")
    end
  end

  #=================================================
  # Private methods
  #=================================================
  private

    def dashboard
      @dashboard ||= MnoEnterprise::Impac::Dashboard.find(params.require(:dashboard_id))
      return render_not_found('dashboard') unless @dashboard
      @dashboard
    end

    def widget
      return nil if (id = params.require(:kpi)[:widget_id]).blank?
      @widget ||= MnoEnterprise::Impac::Widget.find(id)
      return render_not_found('widget') unless @widget
      @widget
    end

    def kpi
      @kpi ||= MnoEnterprise::Impac::Kpi.find(params[:id])
      return @kpi || render_not_found('kpi')
    end

    def kpi_parent
      # TODO: attach kpi onto widget capability
      # widget || dashboard
      dashboard
    end

    def kpi_create_params
      whitelist = [:dashboard_id, :endpoint, :source, :element_watched, {extra_watchables: []}]
      extract_params(whitelist)
    end

    def kpi_update_params
      whitelist = [:name, :element_watched, {extra_watchables: []}]
      extract_params(whitelist)
    end

    def extract_params(whitelist)
      params.require(:kpi).permit(*whitelist).tap do |whitelisted|
        whitelisted[:settings] = params[:kpi][:metadata] || {}
        # TODO: strong params for targets & extra_params attributes (keys will depend on the kpi).
        whitelisted[:targets] = params[:kpi][:targets]
        whitelisted[:extra_params] = params[:kpi][:extra_params]
      end
      .except(:metadata)
    end

    def current_tenant
      @tenant ||= MnoEnterprise::Tenant.get('tenant')
    end

    # TODO: move to MnoHub
    def require_feature_enabled
      return true if current_tenant && current_tenant.kpi_enabled?
      render_forbidden_request(action_name)
    end

    alias :find_valid_kpi  :kpi

end
