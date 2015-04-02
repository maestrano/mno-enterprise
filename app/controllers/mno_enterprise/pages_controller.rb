module MnoEnterprise
  class PagesController < ApplicationController
    before_filter :authenticate_user!, only: [:myspace, :launch]
    before_filter :redirect_to_lounge_if_unconfirmed, only: [:myspace, :launch]
    
    # GET /myspace
    def myspace
      # Meta Information
      @meta[:title] = "Dashboard"
      @meta[:description] = "Dashboard"
      render layout: 'mno_enterprise/application_dashboard'
    end
    
    # GET /launch/:id
    # Redirect to Mno Enterprise app launcher
    # Launching an app (from dashboard) should redirect to this action
    # The true goal of this action is to hide maestrano in the link behind
    # any dashboard app picture
    #
    # TODO: Access + existence checks could be added in the future. This is not
    # mandatory as Mno Enterprise will do it anyway
    def launch
      redirect_to MnoEnterprise.router.launch_url(params[:id], wtk: MnoEnterprise.jwt(user_id: current_user.uid))
    end
  end
end