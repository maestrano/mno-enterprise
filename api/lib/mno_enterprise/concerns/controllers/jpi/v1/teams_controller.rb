module MnoEnterprise::Concerns::Controllers::Jpi::V1::TeamsController
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
  # GET /mnoe/jpi/v1/organizations/:organization_id/teams
  def index
    authorize! :read, orga_relation
    @teams = MnoEnterprise::Team.includes(:organization, :app_instances, :users).where('organization.id': parent_organization_id)
    load_parent_organization(parent_organization_id)
  end

  # GET /mnoe/jpi/v1/teams/:id
  def show
    authorize! :read, orga_relation
    @team = MnoEnterprise::Team.find_one(params[:id], :organization, :app_instances, :users)
    authorize! :read, current_user.orga_relation(@team.organization)
    load_parent_organization(@team.organization.id)
  end

  # POST /mnoe/jpi/v1/organizations/:organization_id/teams
  def create
    authorize! :manage_teams, orga_relation
    @team = MnoEnterprise::Team.create!(create_params)
    MnoEnterprise::EventLogger.info('team_add', current_user.id, 'Team created', @team)
    load_parent_organization(parent_organization_id)
    render 'show'
  end

  # PUT /mnoe/jpi/v1/teams/:id
  def update
    @team = MnoEnterprise::Team.find_one!(params[:id], :organization)
    organization = @team.organization
    authorize! :manage_teams, current_user.orga_relation(organization)
    @team.update_attributes!(update_params)
    # # Update permissions
    if params[:team] && params[:team][:app_instances]
      list = params[:team][:app_instances].select { |e| e != {} }
      MnoEnterprise::EventLogger.info('team_apps_update', current_user.id, 'Team apps updated', @team,
                                      {apps: list.map{|l| l['name']}})
    end
    load_parent_organization(organization.id)
    render 'show'
  end

  # PUT /mnoe/jpi/v1/teams/:id/add_users
  def add_users
    update_members(:add_user)
  end

  # PUT /mnoe/jpi/v1/teams/:id/remove_users
  def remove_users
    update_members(:remove_user)
  end

  # DELETE /mnoe/jpi/v1/teams/:id
  def destroy
    @team = MnoEnterprise::Team.find_one!(params[:id], :organization)
    authorize! :manage_teams, current_user.orga_relation(@team.organization)
    MnoEnterprise::EventLogger.info('team_delete', current_user.id, 'Team deleted', @team)
    @team.destroy!
    head :no_content
  end

  private

  def load_parent_organization(id)
    @parent_organization = MnoEnterprise::Organization.find_one(id, :orga_relations)
  end

  # Update the members of a team
  # Reduce duplication between add and remove
  def update_members(action)
    @team = MnoEnterprise::Team.find_one!(params[:id], :organization)
    organization = @team.organization
    authorize! :manage_teams, current_user.orga_relation(organization)
    if params[:team] && params[:team][:users]
      id_list = params[:team][:users].map { |h| h[:id].to_i }.compact
      # TODO: use a Custom method to update user_ids
      user_ids = case action
                   when :add_user
                     @team.user_ids | id_list
                   when :remove_user
                     @team.user_ids - id_list
                 end
      @team.update_attributes!(user_ids: user_ids)
      MnoEnterprise::EventLogger.info('team_update', current_user.id, 'Team composition updated', @team,
                                      {action: action.to_s, user_ids: user_ids})
    end
    @team = @team.load_required(:organization, :users, :app_instances)
    load_parent_organization(organization.id)
    render 'show'
  end

  def update_params
    update = params.require(:team).permit(:name)
    if params[:team] && params[:team][:app_instances]
      list = params[:team][:app_instances].map { |e| e['id'] }.compact
      update[:app_instance_ids] = list
    end
    update
  end

  def create_params
    params.require(:team).permit(:name).merge(organization_id: parent_organization_id)
  end

end
