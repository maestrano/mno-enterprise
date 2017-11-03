module MnoEnterprise
  class Jpi::V1::BaseResourceController < ApplicationController
    before_filter :check_authorization

    protected
    # Check current user is logged in
    # Check organization is valid if specified
    def check_authorization
      unless current_user
        render nothing: true, status: :unauthorized
        return false
      end
      if params[:organization_id] && !orga_relation
        render nothing: true, status: :forbidden
        return false
      end
      true
    end

    def render_not_found(resource, id = params[:id])
      render json: { errors: { message: "#{resource.titleize} not found (id=#{id})", code: 404, params: params } }, status: :not_found
    end

    def render_bad_request(attempted_action, issue)
      issue = issue.full_messages if issue.respond_to?(:full_messages)
      render json: { errors: { message: "Error while trying to #{attempted_action}: #{issue}", code: 400, params: params } }, status: :bad_request
    end

    def render_forbidden_request(attempted_action)
      render json: { errors: { message: "Error while trying to #{attempted_action}: you do not have permission", code: 403 } }, status: :forbidden
    end
  end
end
