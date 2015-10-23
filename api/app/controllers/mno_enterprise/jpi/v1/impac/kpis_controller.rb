module MnoEnterprise
  class Jpi::V1::Impac::KpisController < Jpi::V1::BaseResourceController
    respond_to :json
    
    # POST /jpi/v1/impac/dashboards/:dashboard_id/kpis
    def create
      whitelist = %w(name endpoint source element_watched targets metadata extra_params)
      attrs = (params[:kpi] || {}).select { |k,v| whitelist.include?(k.to_s) } 

      if dashboard
        authorize! :manage_impac, dashboard

        # TODO: Her will perform a request there which could be avoided
        @kpi = dashboard.kpis.create(attrs)
        if @kpi
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
      whitelist = %w(name element_watched targets extra_params)
      attrs = (params[:kpi] || {}).select { |k,v| whitelist.include?(k.to_s) }.symbolize_keys 
      
      # Find kpi and assign
      # Will call GET kpi route on Maestrano
      @kpi = Impac::Kpi.find(params[:id])
      authorize! :manage_impac, @kpi.dashboard
      if @kpi
        # metadata will be merged instead of replaced
        p = HashWithIndifferentAccess.new(params[:kpi])
        if p[:metadata] && p[:metadata].is_a?(Hash)
          attrs[:metadata] = @kpi.settings.merge(p[:metadata])
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
      # Will call GET kpi route on Maestrano
      @kpi = MnoEnterprise::Impac::Kpi.find(params[:id])
      
      if @kpi
        authorize! :manage_impac, @kpi.dashboard
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
        @dashboard ||= MnoEnterprise::Impac::Dashboard.find(params[:dashboard_id])
      end

  end
end
