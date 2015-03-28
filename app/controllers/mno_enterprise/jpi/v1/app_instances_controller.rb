module MnoEnterprise
  class Jpi::V1::AppInstancesController < Jpi::V1::BaseResourceController

    # GET /jpi/v1/organization/1/apps.json?timestamp=151452452345
    def index
      @app_instances = organization.app_instances.where('updated_at.gt' => Time.at(timestamp)).active
    end
    
  end
end