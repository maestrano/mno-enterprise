module MnoEnterprise
  class Jpi::V1::Impac::KpisController < ApplicationController
    respond_to :json
    
    # POST /jpi/v1/impac/dashboards/:dashboard_id/kpis
    def create
      if kpis
        whitelist = %w(dashboard_id name endpoint source element_watched target metadata extra_param)
        if @kpi = kpis.create(format_attrs(whitelist))
          render 'show'
        else
          render json: @kpi.errors, status: :bad_request
        end
      else
        render json: { errors: "Dashboard id #{params[:id]} doesn't exist" }, status: :not_found
      end
    end
    
    # PUT /jpi/v1/impac/kpis/:id
    def update
      whitelist = %w(name element_watched target extra_param)
      if kpi.update(format_attrs(whitelist))
        render 'show'
      else
        render json: @kpi.errors, status: :bad_request
      end
    end
    
    # DELETE /jpi/v1/impac/kpis/:id
    def destroy
      if kpi.destroy
        head status: :ok
      else
        render json: 'Unable to destroy kpi', status: :bad_request
      end
    end
    
    
    #=================================================
    # Private methods
    #=================================================
    private

      def kpi
        @kpi ||= MnoEnterprise::Impac::Kpi.find(params[:id])
      end

      def kpis
        @kpis ||= MnoEnterprise::Impac::Dashboard.find(params[:dashboard_id]).kpis
      end

      def format_attrs(whitelist)
        attrs = (params[:kpi] || {}).select { |k,v| whitelist.include?(k.to_s) }
        attrs['settings'] = kpi ? kpi.settings || {} : {}
        attrs['settings'].merge!(attrs['metadata']) if attrs['metadata']
        attrs.except!('metadata')
      end

  end
end
