module MnoEnterprise
  class Jpi::V1::Admin::TenantsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/tenant
    def show
      # TODO: load Tenant and cache it?
      @tenant = MnoEnterprise::Tenant.show
    end

    # PATCH /mnoe/jpi/v1/admin/tenant
    def update
      @tenant = MnoEnterprise::Tenant.show
      @tenant.update(tenant_params)

      # TODO: move this somewhere else
      FileUtils.touch('tmp/restart.txt')

      render :show
    end

    protected

    def tenant_params
      # frontend_config is an arbitrary hash
      # On Rails 5.1 use `permit(frontend_config: {})`
      params.require(:tenant).tap do |whitelisted|
        whitelisted[:frontend_config] = params[:tenant][:frontend_config]
      end
    end
  end
end
