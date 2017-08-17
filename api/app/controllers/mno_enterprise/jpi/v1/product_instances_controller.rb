module MnoEnterprise
  class Jpi::V1::ProductInstancesController < Jpi::V1::BaseResourceController
    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/organization/1/product_instances
    def index
      @product_instances = MnoEnterprise::ProductInstance.includes(:product).where('organization_id': parent_organization.id)
      @product_instances
    end

    # POST /mnoe/jpi/v1/organization/1/product_instances
    def create
      product_instance = MnoEnterprise::ProductInstance.create(product_instance_params)
      head :created
    end

    # DELETE /mnoe/jpi/v1/product_instances/1
    def destroy
    end

    private

    def product_instance_params
      params.permit(:product_id).merge(organization_id: parent_organization.id, )
    end
  end
end
