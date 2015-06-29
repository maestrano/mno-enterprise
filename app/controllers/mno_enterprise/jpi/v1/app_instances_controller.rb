module MnoEnterprise
  class Jpi::V1::AppInstancesController < Jpi::V1::BaseResourceController

    # GET /mnoe/jpi/v1/organization/1/apps.json?timestamp=151452452345
    def index
      @app_instances = parent_organization.app_instances.select do |i| 
        i.active? && i.updated_at > Time.at(timestamp) && can?(:access,i)
      end
    end
    
    # DELETE /mnoe/jpi/v1/app_instances/1
    def destroy
      app_instance = MnoEnterprise::AppInstance.find(params[:id])
      
      if app_instance
        authorize! :manage_app_instances, app_instance.owner
        app_instance.terminate
      end
      
      head :accepted
    end
  end
end