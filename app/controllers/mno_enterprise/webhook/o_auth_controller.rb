module MnoEnterprise
  class Webhook::OAuthController < ApplicationController
    before_filter :authenticate_user!
    before_filter :redirect_to_lounge_if_unconfirmed
    
    # GET /mnoe/webhook/:id/authorize
    def authorize
      @app_instance = MnoEnterprise::AppInstance.where(uid: params[:id]).first
      
      # Check authorization
      unless can?(:manage_app_instances, @app_instance.owner)
        redirect_to myspace_path, alert: "You are not authorized to perform this action"
      end
      
      @redirect_to = MnoEnterprise.router.authorize_oauth_url(params[:id], wtk: MnoEnterprise.jwt(user_id: current_user.uid))
    end
    
  end
end