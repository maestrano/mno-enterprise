module MnoEnterprise
  class Jpi::V1::AppInstancesSyncController < Jpi::V1::BaseResourceController

    # GET /mnoe/jpi/v1/organization/org-fbba/app_instances_sync
    def index
      authorize! :check_apps_sync, @parent_organization
      # find method is overriden in the mnoe interface to call organization.check_sync_apps_progress
      connectors = @parent_organization.app_instances_sync.find('anything').connectors
      render json: results(connectors)
    end

    # POST /mnoe/jpi/v1/organizations/org-fbba/app_instances_sync
    def create
      authorize! :sync_apps, @parent_organization
      connectors = @parent_organization.app_instances_sync.create(mode: params[:mode]).connectors
      render json: results(connectors)
    end

    private
      def results(connectors)
        {
          connectors: connectors,
          is_syncing: connectors.any?{|c| c[:status]=="RUNNING" }
        }
      end

  end
end
