module MnoEnterprise
  class Jpi::V1::Impac::WidgetsController < ApplicationController
    respond_to :json
    
    # POST /mnoe/jpi/v1/impac/dashboards/:id/widgets
    #  -> POST /api/mnoe/v1/dashboards/:id/widgets
    def create
      if widgets
        if @widget = widgets.create(format_attrs(['widget_category','metadata']))
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
end