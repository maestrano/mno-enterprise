module MnoEnterprise
  class Jpi::V1::Admin::CloudAppsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/cloud_apps
    def index
      @cloud_apps = MnoEnterprise::App.where(stack: :cloud).all
    end

    # PUT /mnoe/jpi/v1/admin/cloud_apps/:id
    def update
      @cloud_app = MnoEnterprise::App.find_one params[:id]
      @cloud_app.update!(cloud_app_params)
      render :show, status: :ok
    end

    # PUT /mnoe/jpi/v1/admin/cloud_apps/:id/regenerate_api_key
    def regenerate_api_key
      @cloud_app = MnoEnterprise::App.find_one params[:id]
      @cloud_app.regenerate_api_key!
      render :show
    end

    private

    def cloud_app_params
      params.require(:cloud_app).permit(:terms_url, :description, :tiny_description)
    end
  end
end
