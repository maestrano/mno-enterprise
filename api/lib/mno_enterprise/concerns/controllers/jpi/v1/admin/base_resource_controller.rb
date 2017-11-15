module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::BaseResourceController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    ADMIN_CACHE_DURATION = 12.hours
    before_filter :check_authorization
  end

  protected
  
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
