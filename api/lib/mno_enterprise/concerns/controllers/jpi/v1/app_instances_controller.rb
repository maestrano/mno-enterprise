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
  # GET /mnoe/jpi/v1/organization/1/apps.json?timestamp=151452452345
  def index
    @app_instances = parent_organization.app_instances.active.where("updated_at.gt" => Time.at(timestamp)).select do |i|
      # force owner assignment to avoid a refetch in ability can?(:access,i)
      i.owner = parent_organization
      can?(:access,i)
    end
  end

  # POST /mnoe/jpi/v1/organization/1/app_instances
  def create
    authorize! :manage_app_instances, parent_organization
    app_instance = parent_organization.app_instances.create(product: params[:nid])
    head :created
  end

  # DELETE /mnoe/jpi/v1/app_instances/1
  def destroy
    app_instance = MnoEnterprise::AppInstance.find(params[:id])

    if app_instance
      authorize! :manage_app_instances, app_instance.owner
      MnoEnterprise::EventLogger.info('app_destroy', current_user.id, "App destroyed", app_instance.name,app_instance)
      app_instance.terminate
    end

    head :accepted
  end
end
