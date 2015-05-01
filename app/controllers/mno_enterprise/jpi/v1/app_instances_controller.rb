module MnoEnterprise
  class Jpi::V1::AppInstancesController < Jpi::V1::BaseResourceController

    # GET /mnoe/jpi/v1/organization/1/apps.json?timestamp=151452452345
    def index
      @app_instances = parent_organization.app_instances.select { |i| i.active? && i.updated_at > Time.at(timestamp) }
    end
    
    # DELETE /mnoe/jpi/v1/app_instances/1
    def destroy
      app_instance = MnoEnterprise::AppInstance.find(params[:id])
      authorize! :manage_app_instances, app_instance.owner
      app_instance.terminate if app_instance
      
      head :accepted
    end
  end
end