module MnoEnterprise
  class Jpi::V1::Admin::Impac::DashboardsController < Jpi::V1::Admin::BaseResourceController
    skip_before_action :block_support_users, only: [:index]
    before_filter :authorize_support, only: [:index]

    # GET /mnoe/jpi/v1/admin/impac/dashboards
    def index
      @dashboards = MnoEnterprise::Dashboard.apply_query_params(params).to_a
    end

    private

    def authorize_support
      return unless current_user.support?

      case params.dig('where', 'owner_type')
      when 'User'
        authorize!(:read, MnoEnterprise::User.new(id: params.dig('where', 'owner_id')))
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
