module MnoEnterprise
  class Jpi::V1::Admin::AppInstancesController < Jpi::V1::Admin::BaseResourceController

    # DELETE /mnoe/jpi/v1/app_instances/1
    def destroy
      app_instance = MnoEnterprise::AppInstance.find(params[:id])

      if app_instance
        MnoEnterprise::EventLogger.info('app_destroy', current_user.id, 'App destroyed', app_instance)
        app_instance.terminate
      end

      head :accepted
    end
  end
end
