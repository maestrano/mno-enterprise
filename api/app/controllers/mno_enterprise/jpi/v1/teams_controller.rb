# This controller uses nesting (under organizations) and shallow routes
module MnoEnterprise
  class Jpi::V1::TeamsController < Jpi::V1::BaseResourceController
    respond_to :json

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
      end

      render 'show'
    end

    # PUT /mnoe/jpi/v1/teams/:id/add_users
    def add_users
      @team = MnoEnterprise::Team.find(params[:id])
      authorize! :manage_teams, @team.organization

      # Add users
      if params[:team] && params[:team][:users]
        id_list = params[:team][:users].map { |h| h[:id] }.compact
        users = @team.organization.users.where('id.in' => id_list)
        users.each { |u| @team.add_user(u) }
      end

      render 'show'
    end

    # PUT /mnoe/jpi/v1/teams/:id/remove_users
    def remove_users
      @team = MnoEnterprise::Team.find(params[:id])
      authorize! :manage_teams, @team.organization

      # Add users
      if params[:team] && params[:team][:users]
        id_list = params[:team][:users].map { |h| h[:id] }.compact
        users = @team.organization.users.where('id.in' => id_list)
        users.each { |u| @team.remove_user(u) }
      end

      render 'show'
    end

    # DELETE /mnoe/jpi/v1/teams/:id
    def destroy
      @team = MnoEnterprise::Team.find(params[:id])
      authorize! :manage_teams, @team.organization
      @team.destroy

      head :no_content
    end

    private

    def team_params
      params.require(:team).permit(:name)
    end
  end
end
