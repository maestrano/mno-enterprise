module MnoEnterprise
  class Jpi::V1::BaseResourceController < ApplicationController
    before_filter :check_authorization
    
    helper_method :timestamp, :organization
    
    protected

      def timestamp
        @timestamp ||= (params[:timestamp] || 0).to_i
      end

      def organization
        @organization ||= current_user.organizations.to_a.find { |o| o.id.to_s == params[:organization_id].to_s }
      end

      # Check current user is logged in
      # Check organization is valid if specified
      def check_authorization
        unless current_user && (!params[:organization_id] || organization)
          render json: "Unauthorized", status: :unauthorized
          return false
        end
        true
      end
  end
end