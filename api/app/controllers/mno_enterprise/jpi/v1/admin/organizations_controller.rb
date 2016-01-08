module MnoEnterprise
  class Jpi::V1::Admin::OrganizationsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/organizations
    def index
      @organizations = MnoEnterprise::Organization
      @organizations = @organizations.limit(params[:limit]) if params[:limit]
      @organizations = @organizations.skip(params[:offset]) if params[:offset]
      @organizations = @organizations.order_by(params[:order_by]) if params[:order_by]
      @organizations = @organizations.where(params[:where]) if params[:where]
      @organizations = @organizations.all

      response.headers['X-Total-Count'] = @organizations.metadata[:pagination][:count]
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
