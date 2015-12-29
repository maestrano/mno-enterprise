module MnoEnterprise
  class Jpi::V1::Admin::CloudAppsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/cloud_apps
    def index
      @apps = MnoEnterprise::App.cloud.all
    end

    # PUT /mnoe/jpi/v1/admin/cloud_apps/:id/regenerate_api_key
    def regenerate_api_key
      @app = MnoEnterprise::App.find(params[:id])
      @app.regenerate_api_key!

      render :show
    end

    # PUT /mnoe/jpi/v1/admin/cloud_apps/:id/refresh_metadata
    def refresh_metadata
      @app = MnoEnterprise::App.find(params[:id])
      @app.refresh_metadata!

      render :show
    end
  end
end
