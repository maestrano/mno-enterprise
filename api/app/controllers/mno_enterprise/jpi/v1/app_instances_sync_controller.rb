module MnoEnterprise
  class Jpi::V1::AppInstancesSyncController < Jpi::V1::BaseResourceController

    # GET /mnoe/jpi/v1/organization/org-fbba/app_instances_sync
    def index
      authorize! :check_apps_sync, @parent_organization

      # find method is overriden in the mnoe interface to call organization.check_sync_apps_progress
      progress = @parent_organization.app_instances_sync.find('anything')
      connectors = progress.connectors
      errors = progress.errors

      # "Sync Failed" connectors are sorted to end of connectors array.
      connectors.sort_by! do |c|
        date = begin
          c[:last_sync] ? Date.parse(c[:last_sync]) : nil
        rescue ArgumentError => e
          nil
        end

        date || DateTime.new
      end
      .reverse!

      is_syncing = connectors.any? do |c|
        c[:status] ? (c[:status] == 'RUNNING') : false
      end

      last_synced = connectors.first unless is_syncing || connectors.empty?

      render :json => {
        syncing: is_syncing,
        connectors: connectors,
        last_synced: last_synced,
        errors: errors
      }
    end

    # POST /mnoe/jpi/v1/organizations/org-fbba/app_instances_sync
    def create
      authorize! :sync_apps, @parent_organization

      session[:pre_sync_url] = params[:return_url] if params[:return_url]
      app_instances_sync = @parent_organization.app_instances_sync.create(mode: params[:mode])
      connectors = app_instances_sync.connectors

      if !connectors.include?(false) && connectors.count > 0
        msg = "Syncing your data. This process might take a few minutes."
        # can flash be used on mnoe?
        flash[:flash_options] = {timeout: 10000}
      elsif connectors.count == 0
        msg = "No apps available for synchronization! Please either add applications to your dashboard or check they're authenticated."
      else
        msg = "We were unable to sync your data. Please retry at a later time."
      end

      render :json => { msg: msg }
    end

  end
end
