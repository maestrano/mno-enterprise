module MnoEnterprise
  class Jpi::V1::Admin::BaseResourceController < ApplicationController
    before_filter :check_authorization

    protected

    def timestamp
      @timestamp ||= (params[:timestamp] || 0).to_i
    end

    def parent_organization
      @parent_organization ||= current_user.organizations.to_a.find { |o| o.id.to_s == params[:organization_id].to_s }
    end

    # Check current user is logged in
    # Check organization is valid if specified
    def check_authorization
      if current_user && current_user.admin_role.present?
        return true
      end
      render nothing: true, status: :unauthorized
      false
    end
  end
end
