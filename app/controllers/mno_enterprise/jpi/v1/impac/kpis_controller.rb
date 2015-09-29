module MnoEnterprise
  class Jpi::V1::Impac::KpisController < ApplicationController
    respond_to :json
    
    # POST /jpi/v1/impac/dashboards/:dashboard_id/kpis
    def create
      whitelist = %w(dashboard_id name endpoint source element_watched target metadata extra_param)
      attrs = (params[:kpi] || {}).select { |k,v| whitelist.include?(k.to_s) } 

      if dashboard
        @kpi = dashboard.kpis.build(attrs)
        authorize! :create, @kpi
        
        if @kpi.save
          render 'show'
        else
          render json: @kpi.errors, status: :bad_request
        end
      else
        render json: { errors: "Dashboard id #{params[:dashboard_id]} doesn't exist" }, status: :not_found
      end
    end
    
    # PUT /jpi/v1/impac/kpis/:id
    def update
      whitelist = %w(name element_watched target extra_param)
      attrs = (params[:kpi] || {}).select { |k,v| whitelist.include?(k.to_s) }.symbolize_keys 
      
      # Find kpi and assign
      @kpi = Impac::Kpi.find_by_id(params[:id])
      if @kpi
        authorize! :update, @kpi

        # metadata will me merged instead of replaced
        p = HashWithIndifferentAccess.new(params[:kpi])
        if p[:metadata] && p[:metadata].is_a?(Hash)
          attrs[:metadata] = @kpi.metadata.merge(p[:metadata])
        end

        if @kpi.update_attributes(attrs)
          render 'show'
        else
          render json: @kpi.errors, status: :bad_request
        end
      else
        render json: { errors: "Kpi id #{params[:id]} doesn't exist" }, status: :not_found
      end
    end
    
    # DELETE /jpi/v1/impac/kpis/:id
    def destroy
      @kpi = MnoEnterprise::Impac::Kpi.find_by_id(params[:id])
      authorize! :destroy, @kpi
      
      if @kpi
        if @kpi.destroy
          head status: :ok
        else
          render json: { errors: 'Unable to delete this widget' }, status: :bad_request
        end
      else
        render json: {errors: "Kpi id #{params[:id]} doesn't exist" }, status: :not_found
      end
    end
    
    
    #=================================================
    # Private methods
    #=================================================
    private

      def dashboard
        return false unless params[:dashboard_id]
        @dashboard ||= MnoEnterprise::Impac::Dashboard.find_by_id(params[:dashboard_id])
      end

  end
end
