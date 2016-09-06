module MnoEnterprise
  class Jpi::V1::AppInstancesSyncController < Jpi::V1::BaseResourceController
    CONNECTOR_STATUS_RUNNING = ['PENDING', 'RUNNING']

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

      # Some weird behaviour with Her and has_one. If app_instances_sync.find is called somewhere before the create,
      # Her won't detect the organization_id as dirty and won't submit it.
      sync = @parent_organization.app_instances_sync.build(mode: params[:mode])
      sync.organization_id_will_change!
      sync.save

      connectors = sync.connectors

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
