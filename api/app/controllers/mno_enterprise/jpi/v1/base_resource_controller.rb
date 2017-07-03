module MnoEnterprise
  class Jpi::V1::BaseResourceController < ApplicationController
    before_filter :check_authorization

    protected

      def timestamp
        @timestamp ||= (params[:timestamp] || 0).to_i
      end

      def is_integer?(string)
        string.to_i.to_s == string
      end

      def parent_organization
        @parent_organization ||= begin
          id_or_uid = params[:organization_id]
          query = is_integer?(id_or_uid) ? id_or_uid : {uid: id_or_uid}
          o = MnoEnterprise::Organization.includes(:orga_relations, :users).find(query).first
          ## check that user is in the organization
          o if o && o.orga_relation(current_user)
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

      def render_not_found(resource, id = params[:id])
        render json: { errors: {message: "#{resource.titleize} not found (id=#{id})", code: 404, params: params} }, status: :not_found
      end

      def render_bad_request(attempted_action, issue)
        render json: { errors: {message: "Error while trying to #{attempted_action}: #{issue}", code: 400, params: params} }, status: :bad_request
      end

      def render_forbidden_request(attempted_action)
        render json: { errors: {message: "Error while trying to #{attempted_action}: you do not have permission", code: 403} }, status: :forbidden
      end
  end
end
