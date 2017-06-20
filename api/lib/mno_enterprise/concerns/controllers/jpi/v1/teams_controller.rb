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
    authorize! :read, parent_organization
    @teams = parent_organization.teams
  end

  # GET /mnoe/jpi/v1/teams/:id
  def show
    @team = MnoEnterprise::Team.find(params[:id])
    authorize! :read, @team.organization
  end

  # POST /mnoe/jpi/v1/organizations/:organization_id/teams
  def create
    authorize! :manage_teams, parent_organization
    @team = parent_organization.teams.create(team_params)

    MnoEnterprise::EventLogger.info('team_add', current_user.id, 'Team created', @team) if @team

    render 'show'
  end

  # PUT /mnoe/jpi/v1/teams/:id
  def update
    @team = MnoEnterprise::Team.find(params[:id])
    authorize! :manage_teams, @team.organization

    # Update regular attributes
    @team.update_attributes(team_params)

    # # Update permissions
    if params[:team] && params[:team][:app_instances]
      list = params[:team][:app_instances].select { |e| e != {} }
      @team.set_access_to(list)

      MnoEnterprise::EventLogger.info('team_apps_update', current_user.id, 'Team apps updated', @team,
                                      {apps: list.map{|l| l['name']}})

    end

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
    @team = MnoEnterprise::Team.find(params[:id])
    authorize! :manage_teams, @team.organization

    @team.destroy

    MnoEnterprise::EventLogger.info('team_delete', current_user.id, 'Team deleted', @team) if @team

    head :no_content
  end

  private

  # Update the members of a team
  # Reduce duplication between add and remove
  def update_members(action)
    @team = MnoEnterprise::Team.find(params[:id])
    authorize! :manage_teams, @team.organization

    if params[:team] && params[:team][:users]
      id_list = params[:team][:users].map { |h| h[:id] }.compact
      users = @team.organization.users.where('id.in' => id_list)

      users.each { |u| @team.send(action, u) }

      MnoEnterprise::EventLogger.info('team_update', current_user.id, 'Team composition updated', @team,
                                      {action: action.to_s, users:  users.map(&:email)})
    end

    render 'show'
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
