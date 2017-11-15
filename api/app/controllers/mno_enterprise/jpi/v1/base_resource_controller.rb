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
  end
end
