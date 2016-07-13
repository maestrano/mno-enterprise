module MnoEnterprise::Concerns::Controllers::OrgInvitesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :authenticate_user!
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /org_invites/1?token=HJuiofjpa45A73255a74F534FDfds
  def show
    @current_user = current_user
    @org_invite = MnoEnterprise::OrgInvite.active.where(id: params[:id], token: params[:token]).first
    redirect_path = mnoe_home_path

    if @org_invite && !@org_invite.expired? && @org_invite.accept!(current_user)
      redirect_path = add_param_to_fragment(redirect_path.to_s, 'dhbRefId', @org_invite.organization.id)
      message = { notice: "You are now part of #{@org_invite.organization.name}" }
      yield(:success, @org_invite) if block_given?
    elsif @org_invite && @org_invite.expired?
      message = { alert: "It looks like this invite has expired. Please ask your company administrator to resend the invite." }
    else
      message = { alert: "Unfortunately, this invite does not seem to be valid." }
    end

    # Add flash msg in url fragment for the new frontend
    type, msg = message.first
    type = (type == :alert ? :error : :success)
    redirect_path = add_param_to_fragment(redirect_path.to_s, 'flash', [{msg: msg,  type: type}.to_json])

    redirect_to redirect_path, message
  end
end
