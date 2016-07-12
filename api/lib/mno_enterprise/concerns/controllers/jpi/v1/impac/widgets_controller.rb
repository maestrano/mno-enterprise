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
  # POST /mnoe/jpi/v1/impac/dashboards/:id/widgets
  #  -> POST /api/mnoe/v1/dashboards/:id/widgets
  def create
    if widgets
      if @widget = widgets.create(format_attrs(['widget_category','metadata']))
        MnoEnterprise::EventLogger.info('widget_create', current_user.id, 'Widget Creation', nil, @widget)
        @nocontent = true # no data fetch from Connec!
        render 'show'
      else
        render json: @widget.errors, status: :bad_request
      end
    else
      render json: { errors: "Dashboard id #{params[:id]} doesn't exist" }, status: :not_found
    end
  end

  # PUT /mnoe/jpi/v1/impac/widgets/:id
  def update
    if widget.update(format_attrs(['name','metadata']))
      @nocontent = !params['metadata']
      render 'show'
    else
      render json: @widget.errors, status: :bad_request
    end
  end
  
  # DELETE /mnoe/jpi/v1/impac/dashboards/1
  def destroy
    if widget.destroy
      MnoEnterprise::EventLogger.info('widget_delete', current_user.id, 'Widget Deletion', nil, widget)
      head status: :ok
    else
      render json: 'Unable to destroy widget', status: :bad_request
    end
  end
  
  
  #=================================================
  # Private methods
  #=================================================
  private

    def widget
      @widget ||= MnoEnterprise::Impac::Widget.find(params[:id])
    end

    def widgets
      @widgets ||= MnoEnterprise::Impac::Dashboard.find(params[:dashboard_id]).widgets
    end

    def format_attrs(whitelist)
      attrs = (params[:widget] || {}).select { |k,v| whitelist.include?(k.to_s) }
      attrs['settings'] = widget ? widget.settings || {} : {}
      attrs['settings'].merge!(attrs['metadata']) if attrs['metadata']
      attrs.except!('metadata')
    end
end
