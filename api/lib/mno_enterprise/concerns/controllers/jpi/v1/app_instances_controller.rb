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
    @app_instances = MnoEnterprise::AppInstance.includes(:app).where(owner_id: parent_organization.id, 'status.in': statuses).to_a.select do |i|
      can?(:access,i)
    end
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
      authorize! :manage_app_instances, @app_instance.owner
      MnoEnterprise::EventLogger.info('app_destroy', current_user.id, 'App destroyed', @app_instance)
      @app_instance = @app_instance.terminate.first
    end

    head :accepted
  end
end
