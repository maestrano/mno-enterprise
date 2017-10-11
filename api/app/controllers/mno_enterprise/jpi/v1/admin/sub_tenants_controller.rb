module MnoEnterprise
  class Jpi::V1::Admin::SubTenantsController < Jpi::V1::Admin::BaseResourceController

    before_filter :check_sub_tenant_authorization, only: [:create, :update, :delete]

    # GET /mnoe/jpi/v1/admin/sub_tenants
    def index
      # Index mode
      query = MnoEnterprise::SubTenant.apply_query_params(params)
      @sub_tenants = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end

    # GET /mnoe/jpi/v1/admin/sub_tenants/1
    def show
      @sub_tenant = MnoEnterprise::SubTenant.find_one(params[:id])
    end

    # POST /mnoe/jpi/v1/admin/sub_tenants
    def create
      @sub_tenant = MnoEnterprise::SubTenant.create!(sub_tenant_params)
      render :show
    end

    # PATCH /mnoe/jpi/v1/admin/sub_tenant/:id
    def update
      @sub_tenant = MnoEnterprise::SubTenant.find_one(params[:id])
      @sub_tenant.update!(sub_tenant_params)
      render :show
    end

    # PATCH /mnoe/jpi/v1/admin/organizations/1/update_clients
    def update_clients
      @sub_tenant = MnoEnterprise::SubTenant.find_one(params[:id])
      attributes = params.require(:sub_tenant).permit(add: [], remove: [])
      @sub_tenant.update_clients!({data: {attributes: attributes}})
      render :show
    end

    # PATCH /mnoe/jpi/v1/admin/organizations/1/update_account_managers
    def update_account_managers
      @sub_tenant = MnoEnterprise::SubTenant.find_one(params[:id])
      attributes = params.require(:sub_tenant).permit(add: [], remove: [])
      @sub_tenant.update_account_managers!({data: {attributes: attributes}})
      render :show
    end

    # DELETE /mnoe/jpi/v1/admin/sub_tenant/1
    def destroy
      @sub_tenant = MnoEnterprise::SubTenant.find_one(params[:id])
      @sub_tenant.destroy!
      head :no_content
    end

    def check_sub_tenant_authorization
      authorize! :manage_sub_tenant, MnoEnterprise::SubTenant
    end

    private
    def sub_tenant_params
      params.require(:sub_tenant).permit(:name)
    end
  end
end
