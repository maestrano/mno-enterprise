module MnoEnterprise
  class Jpi::V1::Admin::SubTenantsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/sub_tenants
    def index
      # Index mode
      @sub_tenants = MnoEnterprise::SubTenant
      @sub_tenants = @sub_tenants.limit(params[:limit]) if params[:limit]
      @sub_tenants = @sub_tenants.skip(params[:offset]) if params[:offset]
      @sub_tenants = @sub_tenants.order_by(params[:order_by]) if params[:order_by]
      @sub_tenants = @sub_tenants.where(params[:where]) if params[:where]
      @sub_tenants = @sub_tenants.all
      response.headers['X-Total-Count'] = @sub_tenants.metadata[:pagination][:count]
    end

    # GET /mnoe/jpi/v1/admin/sub_tenants/1
    def show
      @sub_tenant = MnoEnterprise::SubTenant.find(params[:id])
      @sub_tenant_clients = @sub_tenant.clients
      @sub_tenant_account_managers = @sub_tenant.account_managers
    end

    # POST /mnoe/jpi/v1/admin/sub_tenants
    def create
      @sub_tenant = MnoEnterprise::SubTenant.build(sub_tenant_params)

      if @sub_tenant.save
        render :show
      else
        render json: @sub_tenant.errors, status: :bad_request
      end
    end

    # PATCH /mnoe/jpi/v1/admin/sub_tenant/:id
    def update
      # TODO: Use Ability
      if current_user.admin_role == 'admin'
        @sub_tenant = MnoEnterprise::SubTenant.find(params[:id])
        @sub_tenant.update(sub_tenant_params)
        @sub_tenant_clients = @sub_tenant.clients
        @sub_tenant_account_managers = @sub_tenant.account_managers
        render :show
      else
        render :index, status: :unauthorized
      end
    end

    # DELETE /mnoe/jpi/v1/admin/sub_tenant/1
    def destroy
      sub_tenant = MnoEnterprise::SubTenant.find(params[:id])
      sub_tenant.destroy

      head :no_content
    end

    private


    def sub_tenant_params
      params.require(:sub_tenant).permit(:name, client_ids:[], account_manager_ids: [])
    end
  end
end
