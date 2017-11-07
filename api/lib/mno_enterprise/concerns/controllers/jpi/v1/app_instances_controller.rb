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
    @app_instances = MnoEnterprise::AppInstance.includes(:app).where(owner_id: parent_organization.id, 'status.in': statuses, 'fulfilled_only': true).to_a.select do |i|
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
    @app_instance = MnoEnterprise::AppInstance.find_one(params[:id])
    if @app_instance
      organization = MnoEnterprise::Organization.find_one(@app_instance.owner_id)
      authorize! :manage_app_instances, organization
      MnoEnterprise::EventLogger.info('app_destroy', current_user.id, 'App destroyed', @app_instance)
      @app_instance = @app_instance.terminate!
    end

    head :accepted
  end
end
