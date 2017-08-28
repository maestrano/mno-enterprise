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
        MnoEnterprise::SystemManager.restart

        render :show
      else
        render_bad_request('update tenant', @tenant.errors.full_messages)
      end
    end

    # PATCH /mnoe/jpi/v1/admin/tenant/domain
    def update_domain
      @tenant = MnoEnterprise::Tenant.show
      @tenant.update_attributes(tenant_params)
      if @tenant.errors.present?
        return render_bad_request('update tenant domain', @tenant.errors.full_messages)
      end

      domain = MnoEnterprise::SystemManager.update_domain(tenant_params[:domain])
      if domain
        # Need to restart to reconfigure the app
        MnoEnterprise::SystemManager.restart
        render :show
      else
        render_bad_request('update tenant domain', 'platform error')
      end
    end

    # POST /jpi/v1/admin/tenant/ssl_certificates
    def add_certificates
      @tenant = MnoEnterprise::Tenant.show

      cert = MnoEnterprise::SystemManager.add_ssl_certs(
        tenant_cert_params[:domain],
        tenant_cert_params[:certificate],
        tenant_cert_params[:ca_bundle],
        tenant_cert_params[:private_key]
      )

      if cert
        render :show
      else
        render_bad_request('add certificate', 'platform error')
      end
    end

    protected

    def tenant_params
      # frontend_config is an arbitrary hash
      # On Rails 5.1 use `permit(frontend_config: {})`
      # TODO: add all authorized fields (see TenantResource::TENANT_FIELDS in MnoHub)
      params.require(:tenant).permit(:domain).tap do |whitelisted|
        whitelisted[:frontend_config] = params[:tenant][:frontend_config] if params[:tenant].has_key?(:frontend_config)
      end
    end

    def tenant_cert_params
      params.require(:tenant).permit(:domain, :certificate, :private_key, :ca_bundle)
    end
  end
end
