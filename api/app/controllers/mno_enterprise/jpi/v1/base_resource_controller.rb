module MnoEnterprise
  class Jpi::V1::BaseResourceController < ApplicationController
    before_filter :check_authorization

    protected

      def timestamp
        @timestamp ||= (params[:timestamp] || 0).to_i
      end

      def parent_organization
        @parent_organization ||= current_user.organizations.to_a.find do |o|
          key = (params[:organization_id].to_i == 0) ? o.uid : o.id.to_s
          key == params[:organization_id].to_s
        end
      end

      # Check current user is logged in
      # Check organization is valid if specified
      def check_authorization
        unless current_user
          render nothing: true, status: :unauthorized
          return false
        end
        if params[:organization_id] && !parent_organization
          render nothing: true, status: :forbidden
          return false
        end
        true
      end

      def render_not_found(resource)
        render json: { errors: {message: "#{resource.titleize} not found (id=#{params[:id]})", code: 404, params: params} }, status: :not_found
      end

      def render_bad_request(attempted_action, issue)
        render json: { errors: {message: "Error while trying to #{attempted_action}: #{issue}", code: 400, params: params} }, status: :bad_request
      end

      def render_forbidden_request(attempted_action)
        render json: { errors: {message: "Error while trying to #{attempted_action}: you do not have permission", code: 403} }, status: :forbidden
      end
  end
end
