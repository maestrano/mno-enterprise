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
  end
end
