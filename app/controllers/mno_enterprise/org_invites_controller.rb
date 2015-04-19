module MnoEnterprise
  class OrgInvitesController < ApplicationController
    before_filter :authenticate_user!
    
    # GET /org_invites/1?token=HJuiofjpa45A73255a74F534FDfds
    def show
      @current_user = current_user
      @org_invite = MnoEnterprise::OrgInvite.active.where(id: params[:id], token: params[:token]).first
      
      if @org_invite && !@org_invite.expired? && @org_invite.accept!(current_user)
        message = { notice: "You are now part of #{@org_invite.organization.name}" }
      elsif @org_invite && @org_invite.expired?
        message = { alert: "It looks like this invite has expired. Please ask your company administrator to resend the invite." }
      else
        message = { alert: "Unfortunately, this invite does not seem to be valid." }
      end
      
      redirect_to myspace_path, message
    end
    
  end
end