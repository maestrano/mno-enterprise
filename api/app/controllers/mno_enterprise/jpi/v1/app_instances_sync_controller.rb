module MnoEnterprise
  class Jpi::V1::AppInstancesSyncController < Jpi::V1::BaseResourceController
    CONNECTOR_STATUS_RUNNING = ['PENDING', 'RUNNING']

    # GET /mnoe/jpi/v1/organization/org-fbba/app_instances_sync
    def index
      authorize! :check_apps_sync, orga_relation
      connectors = parent_organization.app_instances_sync!
      render json: results(connectors)
    end


    # POST /mnoe/jpi/v1/organizations/org-fbba/app_instances_sync
    def create
      authorize! :sync_apps, orga_relation
      connectors = parent_organization.trigger_app_instances_sync!
      render json: results(connectors)
    end

    private
      def results(connectors)
        {
          connectors: connectors,
          is_syncing: connectors.any? { |c| CONNECTOR_STATUS_RUNNING.include?(c[:status]) }
        }
      end
  end
end
