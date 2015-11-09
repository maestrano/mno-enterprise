module MnoEnterprise
  class Jpi::V1::Admin::OrganizationsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/organizations
    def index
      @organizations = MnoEnterprise::Organization.all
    end

    # GET /mnoe/jpi/v1/admin/organizations/1
    def show
      @organization = MnoEnterprise::Organization.find(params[:id])
    end
  end
end
