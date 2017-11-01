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
    @app_instances = MnoEnterprise::AppInstance.with_params(extra_fields: true).includes(:app).where(owner_id: parent_organization.id, 'status.in': statuses).to_a.select do |i|
      can?(:access,i)
    end
  end

  # GET /mnoe/jpi/v1/organization/1/app_instances/11/setup_form
  def setup_form
    app_instance = MnoEnterprise::AppInstance.find(params[:id]).first
    return render json: {error: "App is not an add_on"} unless app_instance&.stack == 'cloud'

    resp = ::HTTParty.get("#{app_instance.metadata['app']['host']}/setup_form")
    render json: JSON.parse(resp.body)
  rescue => e
    render json: {error: "Unable to load schema form"}, status: :bad_request
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances/11/create_omniauth
  def create_omniauth
    app_instance = MnoEnterprise::AppInstance.find(params[:id]).first
    return render json: {error: "App is not an add_on"} unless app_instance&.stack == 'cloud'

    body = params[:app_instance].merge!(org_uid: MnoEnterprise::Organization.find(params[:organization_id]).first.uid)
    resp = ::HTTParty.post("#{app_instance.metadata['app']['host']}/auth/#{app_instance.name.downcase}/request", body: body)
    render json: JSON.parse(resp.body), status: resp.code
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances/11/sync
  def sync
    app_instance = MnoEnterprise::AppInstance.includes(:app).find(params[:id]).first
    app_meta = app_instance.metadata['app']
    body = {group_id: app_instance.uid, opts: {full_sync: params[:full_sync]}}
    auth = {username: app_instance.app.uid, password: app_instance.app.api_key}
    resp = ::HTTParty.post("#{app_meta['host']}#{app_meta['synchronization_start_path']}", body: body, basic_auth: auth)
    render json: JSON.parse(resp.body), status: resp.code
  end

  # GET /mnoe/jpi/v1/organization/1/app_instances/11/sync_history
  def sync_history
    syncs = MnoEnterprise::AppInstance.find(params[:id]).first.sync_history(params.except(:id, :organization_id, :action, :controller))
    response.headers['x-total-count'] = syncs.meta[:record_count]
    render json: syncs.as_json
  end

  # GET /mnoe/jpi/v1/organization/1/app_instances/11/id_maps
  def id_maps
    id_maps = MnoEnterprise::AppInstance.find(params[:id]).first.id_maps(params.except(:id, :organization_id, :action, :controller))
    response.headers['x-total-count'] = id_maps.meta[:record_count]
    render json: id_maps.as_json
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances/11/disconnect
  def disconnect
    app_instance = MnoEnterprise::AppInstance.includes(:app).find(params[:id]).first
    app_meta = app_instance.metadata['app']
    body = {uid: app_instance.uid}
    auth = {username: app_instance.app.uid, password: app_instance.app.api_key}
    resp = ::HTTParty.post("#{app_meta['host']}/disconnect", body: body, basic_auth: auth)
    render json: JSON.parse(resp.body), status: resp.code
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances
  def create
    authorize! :manage_app_instances, parent_organization
    app_instance = parent_organization.provision_app_instance(params[:nid])
    if app_instance.errors.any?
      render json: app_instance.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('app_add', current_user.id, 'App added', app_instance.first)
      head :created
    end
  end

  # DELETE /mnoe/jpi/v1/app_instances/1
  def destroy
    @app_instance = MnoEnterprise::AppInstance.find_one(params[:id])
    if @app_instance
      organization = MnoEnterprise::Organization.find_one(@app_instance.owner_id)
      authorize! :manage_app_instances, organization
      MnoEnterprise::EventLogger.info('app_destroy', current_user.id, 'App destroyed', @app_instance)
      @app_instance = @app_instance.terminate.first
    end

    head :accepted
  end
end
