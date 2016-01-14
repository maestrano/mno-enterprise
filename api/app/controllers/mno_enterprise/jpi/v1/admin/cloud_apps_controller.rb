module MnoEnterprise
  class Jpi::V1::Admin::CloudAppsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/cloud_apps
    def index
      @cloud_apps = MnoEnterprise::App.cloud.all
    end

    # PUT /mnoe/jpi/v1/admin/cloud_apps/:id/regenerate_api_key
    def regenerate_api_key
      @cloud_app = MnoEnterprise::App.find params[:id]
      @cloud_app.regenerate_api_key!
      render :show
    end

    # PUT /mnoe/jpi/v1/admin/cloud_apps/:id/refresh_metadata
    # params:
    # - metadata_url: the metadata URL
    def refresh_metadata
      @cloud_app = MnoEnterprise::App.find params[:id]
      result = @cloud_app.refresh_metadata! params[:metadata_url]
      if result && result[:errors].blank?
        render :show
      else
        render json: result, status: 400
      end
    end
  end
end
