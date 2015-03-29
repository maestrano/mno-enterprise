module MnoEnterprise
  class Jpi::V1::AppInstancesController < Jpi::V1::BaseResourceController

    # GET /jpi/v1/organization/1/apps.json?timestamp=151452452345
    def index
      @app_instances = parent_organization.app_instances.select { |i| i.active? && i.updated_at > Time.at(timestamp) }
    end
    
  end
end