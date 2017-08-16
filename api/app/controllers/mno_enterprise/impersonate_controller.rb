module MnoEnterprise
  class ImpersonateController < ApplicationController
    include MnoEnterprise::ImpersonateHelper

    before_filter :authenticate_user!, except: [:destroy]
    before_filter :current_user_must_be_admin!, except: [:destroy]

    # Perform the user impersonate action
    # GET /impersonate/user/123
    def create
      session[:impersonator_redirect_path] = params[:redirect_path].presence
      @user = MnoEnterprise::User.find_one(params[:user_id], :deletion_requests, :organizations, :orga_relations, :dashboards)
      if @user.present?
        impersonate(@user)
      else
        flash[:notice] = "User doesn't exist"
      end

      path = mnoe_home_path
      path = add_param_to_fragment(path, 'dhbRefId', params[:dhbRefId]) if params[:dhbRefId].present?

      redirect_to path
    end

    # Revert the user impersonation
    # GET /impersonation/revert
    def destroy
      if current_impersonator
        # user = current_user
        revert_impersonate
      end
      redirect_to session.delete(:impersonator_redirect_path).presence || '/admin/'
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
