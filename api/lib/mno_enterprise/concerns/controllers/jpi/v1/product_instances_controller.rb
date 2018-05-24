module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductInstancesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    DEPENDENCIES = [:app_instance, :'app_instance.app', :product,
                    :'product.values', :'product.values.field', :sync_status]
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/organization/1/product_instances
  def index
    statuses = MnoEnterprise::ProductInstance::ACTIVE_STATUSES.join(',')
    @product_instances = MnoEnterprise::ProductInstance.includes(*DEPENDENCIES).where(organization_id: parent_organization.id, 'status.in': statuses).to_a.select do |i|
      can?(:access_product_instance, i)
    end
  end
end
