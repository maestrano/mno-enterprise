module MnoEnterprise
  class ImpersonateController < ApplicationController
    include MnoEnterprise::ImpersonateHelper

    before_filter :skip_trackable, only: [:create]
    before_filter :authenticate_user!, except: [:destroy]
    before_filter :current_user_must_be_admin!, except: [:destroy]

    # Perform the user impersonate action
    # GET /impersonate/user/123
    def create
      session[:impersonator_redirect_path] = params[:redirect_path].presence
      @user = MnoEnterprise::User.find_one(params[:user_id], :deletion_requests, :organizations, :orga_relations, :dashboards, :teams, :user_access_requests, :sub_tenant)
      unless @user.present?
        return redirect_with_error('User does not exist')
      end
      if @user.admin_role.present?
        return redirect_with_error('User is a staff member')
      end
      if Settings&.admin_panel&.impersonation&.consent_required
        unless @user.access_request_status(current_user) == 'approved'
          return redirect_with_error('Access was not granted or was revoked.' )
        end
      end
      impersonate(@user)
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

    def skip_trackable
      request.env["devise.skip_trackable"] = true
    end

    def current_user_must_be_admin!
      unless current_user.admin_role.present?
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    rescue ActionController::RedirectBackError
      redirect_to '/'
    end

    def redirect_with_error(msg)
      path = session.delete(:impersonator_redirect_path).presence || '/admin/'
      redirect_path = add_param_to_fragment(path, 'flash', [{msg: msg,  type: :error}.to_json])
      redirect_to redirect_path
    end
  end
end
