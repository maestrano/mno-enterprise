module MnoEnterprise
  class Jpi::V1::AppInstancesSyncController < Jpi::V1::BaseResourceController
    CONNECTOR_STATUS_RUNNING = ['PENDING', 'RUNNING']

    # GET /mnoe/jpi/v1/organization/org-fbba/app_instances_sync
    def index
      authorize! :check_apps_sync, @parent_organization
      @parent_organization = parent_organization.app_instances_sync!
      render json: results(parent_organization)
    end

    # POST /mnoe/jpi/v1/organizations/org-fbba/app_instances_sync
    def create
      authorize! :sync_apps, @parent_organization
      org = parent_organization.trigger_app_instances_sync!
      render json: results(org)
    end

    private

    def results(org)
      statuses = MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(',')
      has_running_cube = MnoEnterprise::AppInstance.where('owner.id': org.id, 'status.in': statuses, 'fulfilled_only': true, stack: 'cube').first.present?

      {
        connectors: org.connectors,
        is_syncing: org.connectors.any? { |c| CONNECTOR_STATUS_RUNNING.include?(c[:status]&.upcase) },
        has_running_cube: has_running_cube
      }
    end
  end
end
