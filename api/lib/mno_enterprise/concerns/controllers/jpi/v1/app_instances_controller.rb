module MnoEnterprise::Concerns::Controllers::Jpi::V1::AppInstancesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/organization/1/app_instances
  def index
    statuses = MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(',')
    required_instances_fields = %w(uid stack name status oauth_keys_valid created_at per_user_licence addon_organization channel_id oauth_company app)
    @app_instances = MnoEnterprise::AppInstance.select(required_instances_fields).includes(:app).where(owner_id: parent_organization.id, 'status.in': statuses, 'fulfilled_only': true).to_a.select do |i|
      can?(:access,i)
    end
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances
  def create
    authorize! :manage_app_instances, parent_organization
    app_instance = parent_organization.provision_app_instance!(params[:nid])
    MnoEnterprise::EventLogger.info('app_add', current_user.id, 'App added', app_instance)
    head :created
  end

  # DELETE /mnoe/jpi/v1/app_instances/1
  def destroy
    @app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :owner)
    if @app_instance
      authorize! :manage_app_instances, app_instance.owner
      MnoEnterprise::EventLogger.info('app_destroy', current_user.id, 'App destroyed', @app_instance)
      @app_instance = @app_instance.terminate!
    end

    head :accepted
  end

  # GET /mnoe/jpi/v1/organization/1/app_instances/11/setup_form
  def setup_form
    app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :app, :owner)
    authorize! :manage_app_instances, app_instance.owner
    response = MnoEnterprise::AddOnHelper.send_request(app_instance, :get, '/setup_form')
    render json: JSON.parse(response.body)
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances/11/create_omniauth
  # params[:app_instance] contains the fields values from the setup form
  def create_omniauth
    app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :app, :owner)
    authorize! :manage_app_instances, app_instance.owner
    body = params[:app_instance].merge!(org_uid: app_instance.channel_id)
    response = MnoEnterprise::AddOnHelper.send_request(app_instance, :post, "/auth/#{app_instance.name.downcase}/request", body: body)
    MnoEnterprise::EventLogger.info('addon_create_omniauth', current_user.id, 'Link account to add_on', app_instance)
    render json: JSON.parse(response.body)
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances/11/sync
  def sync
    app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :app, :owner)
    authorize! :manage_app_instances, app_instance.owner
    body = { group_id: app_instance.uid, opts: { full_sync: params[:full_sync] } }
    response = MnoEnterprise::AddOnHelper.send_request(app_instance, :post, app_instance.metadata['app']['synchronization_start_path'], body: body)
    MnoEnterprise::EventLogger.info('addon_syn', current_user.id, 'Launch sync on add_on', app_instance)
    head :accepted
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances/11/disconnect
  def disconnect
    app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :app, :owner)
    authorize! :manage_app_instances, app_instance.owner
    body = { uid: app_instance.uid }
    response = MnoEnterprise::AddOnHelper.send_request(app_instance, :post, '/disconnect', body: body)
    MnoEnterprise::EventLogger.info('addon_disconnect', current_user.id, 'Unlink account from add_on', app_instance)
    head :accepted
  end

  # GET /mnoe/jpi/v1/organization/1/app_instances/11/sync_history
  # params should respect JSON Api specification
  def sync_history
    app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :owner)
    authorize! :manage_app_instances, app_instance.owner
    syncs = app_instance.sync_history(params.except(:id, :organization_id, :action, :controller))
    response.headers['x-total-count'] = syncs.meta[:record_count]
    MnoEnterprise::EventLogger.info('addon_sync_history', current_user.id, 'Get list of add_on syncs', app_instance)
    render json: syncs.as_json
  end

  # GET /mnoe/jpi/v1/organization/1/app_instances/11/id_maps
  # params should respect JSON Api specification
  def id_maps
    app_instance = MnoEnterprise::AppInstance.find_one(params[:id], :owner)
    authorize! :manage_app_instances, app_instance.owner
    id_maps = app_instance.id_maps(params.except(:id, :organization_id, :action, :controller))
    response.headers['x-total-count'] = id_maps.meta[:record_count]
    MnoEnterprise::EventLogger.info('addon_id_maps', current_user.id, 'Get list of add_on id_maps', app_instance)
    render json: id_maps.as_json
  end
end
