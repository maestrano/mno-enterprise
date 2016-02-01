module MnoEnterprise
  class ImpersonateController < ApplicationController
    include MnoEnterprise::ImpersonateHelper

    before_filter :authenticate_user!, except: ["revert"]
    before_filter :current_user_must_be_admin!, except: ["revert"]

    # Perform the user impersonate action
    # GET /impersonate/user/123
    def create
      @user = MnoEnterprise::User.find(params[:user_id])
      if @user.present?
        impersonate(@user)
      else
        flash[:notice] = "User doesn't exist"
      end
      redirect_to mnoe_home_path
    end

    # Revert the user impersonation
    # GET /impersonation/revert
    def revert
      if current_impersonator
        user = current_user
        revert_impersonate
      end
      redirect_to '/admin/'
    end

    private

    def current_user_must_be_admin!
      unless current_user.admin_role.present?
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    rescue ActionController::RedirectBackError
      redirect_to '/'
    end
  end
end
