module MnoEnterprise
  class Webhook::OAuthController < ApplicationController
    before_filter :authenticate_user!, only: [:authorize, :disconnect, :sync]
    before_filter :redirect_to_lounge_if_unconfirmed
    before_filter :check_permissions, only: [:authorize, :disconnect, :sync]
    
    # GET /mnoe/webhook/oauth/:id/authorize
    def authorize      
      @redirect_to = MnoEnterprise.router.authorize_oauth_url(params[:id], wtk: MnoEnterprise.jwt(user_id: current_user.uid))
    end
    
    # GET /mnoe/webhook/oauth/:id/callback
    def callback
      redirect_to myspace_path
    end
    
    # GET /mnoe/webhook/oauth/:id/disconnect
    def disconnect
      redirect_to MnoEnterprise.router.disconnect_oauth_url(params[:id], wtk: MnoEnterprise.jwt(user_id: current_user.uid))
    end
    
    # GET /mnoe/webhook/oauth/:id/sync
    def sync
      redirect_to MnoEnterprise.router.sync_oauth_url(params[:id], wtk: MnoEnterprise.jwt(user_id: current_user.uid))
    end
    
    private
      def app_instance
        @app_instance ||= MnoEnterprise::AppInstance.where(uid: params[:id]).first
      end
      
      # Redirect with an error if user is unauthorized
      def check_permissions
        unless can?(:manage_app_instances, app_instance.owner)
          redirect_to myspace_path, alert: "You are not authorized to perform this action"
          return false
        end
        true
      end
  end
end