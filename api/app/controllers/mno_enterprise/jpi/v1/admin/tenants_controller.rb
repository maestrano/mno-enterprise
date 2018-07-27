module MnoEnterprise
  class Jpi::V1::Admin::TenantsController < Jpi::V1::Admin::BaseResourceController
    before_action :fix_json_params, only: :update

    # GET /mnoe/jpi/v1/admin/tenant
    def show
      # TODO: load Tenant and cache it?
      @tenant = MnoEnterprise::Tenant.show
    end

    # PATCH /mnoe/jpi/v1/admin/tenant
    def update
      timestamp = Time.current.to_i
      params[:tenant].deep_merge!(frontend_config: { config_timestamp: timestamp })

      @tenant = MnoEnterprise::Tenant.show
      @tenant.update_attributes!(tenant_params)
      # Need to re-retrieve the tenant with tenant company after
      # update_attributes! call
      @tenant = MnoEnterprise::Tenant.show

      MnoEnterprise::SystemManager.restart(timestamp)
      render :show
    end

    # GET /mnoe/jpi/v1/admin/tenant/restart_status
    def restart_status
      status = MnoEnterprise::SystemManager.restart_status
      render json: { status: status }
    end

    # PATCH /mnoe/jpi/v1/admin/tenant/domain
    def update_domain
      @tenant = MnoEnterprise::Tenant.show
      @tenant.update_attributes!(tenant_params)
      # Need to re-retrieve the tenant with tenant company after
      # update_attributes! call
      @tenant = MnoEnterprise::Tenant.show
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
        whitelisted[:plugins_config] = params[:tenant][:plugins_config] if params[:tenant].has_key?(:plugins_config)
      end
    end

    def tenant_cert_params
      params.require(:tenant).permit(:domain, :certificate, :private_key, :ca_bundle)
    end

    # Bypass Rails `deep_munge` which replace empty arrays by nil:
    #   Value for params[:...][:available_locales] was set to nil, because it was one of [], [null] or [null, null, ...].
    #
    # See http://guides.rubyonrails.org/v4.2/security.html#unsafe-query-generation for more information.
    #
    # We can remove this once migrating to Rails 5 as the behavior has changed in Rails 5:
    # +------------------+--------------------+-------------------+
    # | JSON             | Params (Rails 4.2) | Params (Rails 5)  |
    # +------------------+--------------------+-------------------+
    # | { "person": [] } | { :person => nil } | { :person => [] } |
    # +------------------+--------------------+-------------------+
    def fix_json_params
      if request.format.json?
        body = request.body.read
        request.body.rewind
        unless body == ''
          unmunged_body = ActiveSupport::JSON.decode(body)
          params.merge!(unmunged_body)
        end
      end
    end
  end
end
