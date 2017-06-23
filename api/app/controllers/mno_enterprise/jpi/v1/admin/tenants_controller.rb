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
      @tenant.update_attributes(tenant_params)

      if @tenant.errors.empty?
        MnoEnterprise::AppManager.restart

        render :show
      else
        render_bad_request('update tenant', @tenant.errors)
      end
    end

    protected

    def tenant_params
      # frontend_config is an arbitrary hash
      # On Rails 5.1 use `permit(frontend_config: {})`
      # TODO: add all authorized fields (see TenantResource::TENANT_FIELDS in MnoHub)
      params.require(:tenant).permit(:domain).tap do |whitelisted|
        whitelisted[:frontend_config] = params[:tenant][:frontend_config]
      end
    end
  end
end
