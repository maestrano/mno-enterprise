module MnoEnterprise
  class Jpi::V1::Admin::TeamsController < Jpi::V1::Admin::BaseResourceController

   RELATIONSHIPS = [:organization, :app_instances, :users]

    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/admin/organizations/1/teams
    def index
      authorize! :read, parent_organization
      if params[:terms]
        # Search mode
        @teams = []
        JSON.parse(params[:terms]).map { |t| @teams = @teams | fetch_all_teams(params[:organization_id]).where(Hash[*t]) }
        response.headers['X-Total-Count'] = @teams.count
      else
        query = fetch_teams(params[:organization_id])
        @teams = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    protected

    def fetch_all_teams(organization_id)
      MnoEnterprise::Team
        .apply_query_params(params)
        .includes(RELATIONSHIPS)
        .where(organization_id: organization_id)
    end

    def fetch_teams(organization_id)
      MnoEnterprise::Team
        .apply_query_params(params)
        .includes(RELATIONSHIPS)
        .where(organization_id: organization_id)
    end
  end
end
