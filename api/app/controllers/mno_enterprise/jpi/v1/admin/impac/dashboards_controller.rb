module MnoEnterprise
  class Jpi::V1::Admin::Impac::DashboardsController < Jpi::V1::Admin::BaseResourceController
    skip_before_action :block_support_users, only: [:index]
    before_filter :authorize_support, only: [:index]

    DASHBOARD_DEPENDENCIES = [:widgets, :kpis]

    # GET /mnoe/jpi/v1/admin/impac/dashboards
    def index
      query = MnoEnterprise::Dashboard
        .apply_query_params(params)
        .includes(*DASHBOARD_DEPENDENCIES)

      response.headers['X-Total-Count'] = query.meta.record_count

      @dashboards = query.to_a
    end

    private

    def authorize_support
      return unless current_user.support?

      case params.dig('where', 'owner_type')
      when 'User'
        authorize!(:read, MnoEnterprise::User.find_one(params.dig('where', 'owner_id'), :organizations, :orga_relations))
      when 'Organization'
        authorize!(:read, MnoEnterprise::Organization.new(id: params.dig('where', 'owner_id')))
      else
        return head :forbidden
      end
    end

    def valid_support_search?
      params.dig('where', 'owner_id') && params.dig('where', 'owner_type') == 'User'
    end
  end
end
