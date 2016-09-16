module MnoEnterprise::Concerns::Controllers::Jpi::V1::Impac::KpisController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json

    before_filter :require_valid_dashboard, only: [:create]
    before_filter :find_valid_widget, only: [:create]
    before_filter :find_valid_kpi, only: [:update, :delete]
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/impac/kpis
  def discover
    render json: {}
  end

  # POST /mnoe/jpi/v1/impac/dashboards/:dashboard_id/kpis
  def create
    authorize! :manage_kpi, dashboard
    # TODO: Her will perform a request there which could be avoided
    if @kpi = dashboard.kpis.create(kpi_create_params)
      render 'show'
    else
      render_bad_request('create kpi', kpi.errors)
    end
  end

  # PUT /mnoe/jpi/v1/impac/kpis/:id
  #   -> PUT /api/mnoe/v1/kpis/:id
  def update
    authorize! :manage_kpi, kpi

    if kpi.update(kpi_update_params)
      render 'show'
    else
      render_bad_request('update kpi', kpi.errors)
    end
  end

  # DELETE /mnoe/jpi/v1/impac/kpis/:id
  #   -> DELETE /api/mnoe/v1/kpis/:id
  def destroy
    authorize! :manage_kpi, kpi

    if kpi.destroy
      head status: :ok
    else
      render_bad_request('destroy kpi', 'Unable to delete this kpi')
    end
  end

  #=================================================
  # Private methods
  #=================================================
  private

    def dashboard
      @dashboard ||= MnoEnterprise::Impac::Dashboard.find(params[:dashboard_id])
      return render_not_found('dashboard') unless @dashboard
      @dashboard
    end

    def widget
      @widget ||= MnoEnterprise::Impac::Widget.find(id)
      return render_not_found('widget') unless @widget
      @widget
    end

    def kpi
      @kpi ||= MnoEnterprise::Impac::Kpi.find(params[:id])
      return render_not_found('kpi') unless @kpi
      @kpi
    end

    def kpi_create_params
      whitelist = [:dashboard_id, :endpoint, :source, :element_watched, {extra_watchables: []}]
      extract_params(whitelist)
    end

    def kpi_update_params
      whitelist = [:name, :element_watched, :targets, {extra_watchables: []}]
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

    def find_valid_widget
      return true if (id = params[:kpi][:widget_id]).blank?
      widget
    end

    alias :require_valid_dashboard  :dashboard
    alias :find_valid_kpi  :kpi

end
