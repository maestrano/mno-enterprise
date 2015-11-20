module MnoEnterprise
  class ImpersonateController < ApplicationController
    include MnoEnterprise::ImpersonateHelper

    before_filter :authenticate_user!, except: ["destroy"]
    before_filter :current_user_must_be_admin!, except: ["destroy"]

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
    # DELETE /impersonation/revert
    def destroy
      if current_impersonator
        user = current_user
        revert_impersonate
        if user
          flash[:notice] = "No longer impersonating #{user}"
        else
          flash[:notice] = "No longer impersonating a user"
        end
      else
        flash[:notice] = "You weren't impersonating anyone"
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
