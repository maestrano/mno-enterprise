module MnoEnterprise
  class Jpi::V1::Admin::OrganizationsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/organizations
    def index
      if params[:top] || params[:skip]
        @organizations = MnoEnterprise::Organization.limit(params[:top]).skip(params[:skip]).all
      else
        @organizations = MnoEnterprise::Organization.all
      end
    end

    # GET /mnoe/jpi/v1/admin/organizations/1
    def show
      @organization = MnoEnterprise::Organization.find(params[:id])
      @organization_active_apps = @organization.app_instances.select { |app| app.status == "running" }
    end

    # GET /mnoe/jpi/v1/admin/organizations/in_arrears
    def in_arrears
      @arrears = MnoEnterprise::ArrearsSituation.all
    end
  end
end
