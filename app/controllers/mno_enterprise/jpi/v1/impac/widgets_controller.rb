module MnoEnterprise
  class Jpi::V1::Impac::WidgetsController < ApplicationController
    respond_to :json

  	# GET /js_api/v1/analytics/widgets/1
	  def show
	    @widget = MnoEnterprise::Impac::Widget.find(params[:id])
      render json: { errors: "Widget id #{params[:id]} doesn't exist" }, status: :not_found unless @widget
	  end
	  
	  # # Nested route
	  # # POST /js_api/v1/analytics/dashboards/1/widgets
	  # def create
	  #   whitelist = ['widget_category','metadata']
	  #   attrs = (params[:widget] || {}).select { |k,v| whitelist.include?(k.to_s) } 

	  #   if dashboard
	  #     @widget = dashboard.widgets.build(attrs)
	  #     authorize! :create, @widget
	      
	  #     if @widget.save
	  #       @nocontent = true # no data fetch from Connec!
	  #       render 'show'
	  #     else
	  #       render json: @widget.errors, status: :bad_request
	  #     end
	  #   else
	  #     render json: { errors: "Dashboard id #{params[:dashboard_id]} doesn't exist" }, status: :not_found
	  #   end
	  # end
	  
	  # # PUT /js_api/v1/analytics/widgets/1
	  # def update
	  #   whitelist = ['name','metadata']
	  #   attrs = (params[:widget] || {}).select { |k,v| whitelist.include?(k.to_s) }.symbolize_keys 
	    
	  #   # Find widget and assign
	  #   @widget = Analytics::Widget.find_by_id(params[:id])
	  #   if @widget
	  #     # Check
	  #     authorize! :update, @widget

	  #     if !attrs[:metadata] || attrs[:metadata].is_a?(Hash)
	  #       @widget.assign_attributes(name: (attrs[:name] || @widget.name), metadata: (@widget.metadata || {}).merge(attrs[:metadata] || {}))
	  #       if @widget.save
	  #         # No data fetch from Connec! unless there were some metadata changes
	  #         @nocontent = !attrs[:metadata] 
	  #         render 'show'
	  #       else
	  #         render json: @widget.errors, status: :bad_request
	  #       end
	  #     else
	  #       render json: { errors: ":metadata must be a hash" }, status: :bad_request
	  #     end
	  #   else
	  #     render json: { errors: "Widget id #{params[:id]} doesn't exist" }, status: :not_found
	  #   end
	  # end
	  
	  # # DELETE /js_api/v1/analytics/widgets/1
	  # def destroy
	  #   @widget = Analytics::Widget.find_by_id(params[:id])
	  #   authorize! :destroy, @widget
	    
	  #   if @widget
	  #     if @widget.destroy
	  #       if @widget.dashboard
	  #         # Remove the widget from the widget_order list of the corresponding dashboard
	  #         @widget.dashboard.metadata ||= {}
	  #         metadata = @widget.dashboard.metadata.merge({
	  #           widgets_order: (@widget.dashboard.metadata[:widgets_order] || []).reject { |id| id==params[:id].to_i }
	  #         })
	  #         @widget.dashboard.update_attribute(:metadata, metadata)
	  #       end

	  #       head status: :ok
	  #     else
	  #       render json: { errors: 'Unable to delete this widget' }, status: :bad_request
	  #     end
	  #   else
	  #     render json: {errors: "Widget id #{params[:id]} doesn't exist" }, status: :not_found
	  #   end
	  # end
	  
	  
	  # #=================================================
	  # # Private methods
	  # #=================================================
	  # private

	  #   def dashboard
	  #     @dashboard ||= Analytics::Dashboard.find_by_id(params[:dashboard_id])
	  #   end

	end
end