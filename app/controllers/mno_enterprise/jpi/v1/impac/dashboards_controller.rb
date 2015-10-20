module MnoEnterprise
  class Jpi::V1::Impac::DashboardsController < Jpi::V1::BaseResourceController
    respond_to :json

	  # GET /mnoe/jpi/v1/impac/dashboards
	  def index
	    dashboards
	  end
	  
	  # GET /mnoe/jpi/v1/impac/dashboards/1
	  def show
	    dashboard
	    render json: { errors: "Dashboard id #{params[:id]} doesn't exist" }, status: :not_found unless @dashboard
	  end
	  
	  # POST /mnoe/jpi/v1/impac/dashboards
	  #  -> POST /api/mnoe/v1/users/282/dashboards
	  def create
	    whitelist = ['name','organization_ids']
	    attrs = (params[:dashboard] || {}).select { |k,v| whitelist.include?(k.to_s) }
	    
	    if @dashboard = dashboards.create(attrs)
	    	# authorize! :create, @dashboard
	    	render 'show'
	    else
		    render json: @dashboard.errors, status: :bad_request
		  end
	  end

	  # PUT /mnoe/jpi/v1/impac/dashboards/1
	  def update
	    whitelist = ['name','widgets_order','organization_ids']
	    attrs = (params[:dashboard] || {}).select { |k,v| whitelist.include?(k.to_s) }

      if dashboard.update(attrs)
	      # dashboard.assign_attributes(attrs)
	      # authorize! :update, dashboard
	      render 'show'
	    else
		    render json: @dashboard.errors, status: :bad_request
	    end
	  end
	  
	  # DELETE /mnoe/jpi/v1/impac/dashboards/1
	  def destroy
	    # authorize! :destroy, @dashboard
	    if dashboard.destroy
	      head status: :ok
	    else
	      render json: 'Unable to destroy dashboard', status: :bad_request
	    end
	  end

    
    protected
      def dashboard
        @dashboard ||= current_user.dashboards.to_a.find { |d| d.id.to_s == params[:id].to_s }
      end

      def dashboards
      	@dashboards ||= current_user.dashboards
      end

  end
end