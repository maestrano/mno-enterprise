module MnoEnterprise
  class Jpi::V1::Impac::DashboardsController < ApplicationController
    respond_to :json

	  # GET /mnoe/jpi/v1/impac/dashboards
	  def index
	    @dashboards ||= current_user.dashboards
	  end
	  
	  # GET /mnoe/jpi/v1/impac/dashboards/1
	  def show
	    @dashboard = MnoEnterprise::Impac::Dashboard.find(params[:id])
	    render json: { errors: "Dashboard id #{params[:id]} doesn't exist" }, status: :not_found unless @dashboard
	  end
	  
	  # POST /mnoe/jpi/v1/impac/dashboards
	  def create
	    whitelist = ['name','organization_ids']
	    attrs = (params[:dashboard] || {}).select { |k,v| whitelist.include?(k.to_s) }
	    
	    @dashboard = current_user.dashboards.create(attrs)
	    # authorize! :create, @dashboard
	    
	    if @dashboard
	    	render 'show'
	    else
		    render json: @dashboard.errors, status: :bad_request
		  end
	  end

	  # PUT /mnoe/jpi/v1/impac/dashboards/1
	  def update
	    whitelist = ['name','widgets_order']
	    attrs = (params[:data] || {}).select { |k,v| whitelist.include?(k.to_s) }

      dashboard.update(attrs)
      # dashboard.assign_attributes(attrs)
      # authorize! :update, dashboard
	    
	    if @dashboard
	      render 'show'
	    else
		    render json: @dashboard.errors, status: :bad_request
	    end
	  end
	  
	  # # DELETE /mnoe/jpi/v1/impac/dashboards/1
	  # def destroy
	  #   # Find & authorize
	  #   @dashboard = MnoEnterprise::Impac::Dashboard.find(params[:id])
	  #   # authorize! :destroy, @dashboard
	    
	  #   if @dashboard && @dashboard.destroy
	  #     head status: :ok
	  #   else
	  #     render json: 'Unable to destroy dashboard', status: :bad_request
	  #   end
	  # end

    
    protected
      def dashboard
        @dashboard ||= current_user.dashboards.to_a.find { |d| d.id.to_s == params[:id].to_s }
      end

  end
end