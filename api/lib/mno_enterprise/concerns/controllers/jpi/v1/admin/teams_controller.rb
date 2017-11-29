module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::TeamsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/organizations/1/teams
  def index
    if params[:terms]
      # Search mode
      @teams = []
      JSON.parse(params[:terms]).map { |t| @teams = @teams | fetch_teams(params[:organization_id]).where(Hash[*t]) }
      response.headers['X-Total-Count'] = @teams.count
    else
      query = fetch_teams(params[:organization_id])
      @teams = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end
    @parent_organization = MnoEnterprise::Organization.find_one(params[:organization_id], :orga_relations)
  end

  protected

  def fetch_teams(organization_id)
    MnoEnterprise::Team
      .apply_query_params(params)
      .where('organization.id': organization_id)
      .includes(:app_instances, :users, app_instances: :app)
      .with_params(fields:{
        teams: 'id,name,app_instances,users',
        app_instances:'id,name,app',
        users: 'id,name,surname,email',
        apps: 'logo'
      })
  end
end
