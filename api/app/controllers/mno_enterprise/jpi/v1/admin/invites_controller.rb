module MnoEnterprise::Jpi::V1::Admin
  # Manage invitation sending
  class InvitesController < BaseResourceController
    def create
      @organization = MnoEnterprise::Organization.find_one(params[:organization_id], :orga_relations)
      user = MnoEnterprise::User.find_one(params[:user_id])
      return render json: {error: 'Could not find account or user'}, status: :not_found unless @organization && user

      if user.confirmed?
        invite = find_org_invite(@organization, user)
        return render json: {error: 'No active invitation found'}, status: :not_found unless invite
        send_org_invite(invite)
      else
        user.resend_confirmation_instructions
      end

      MnoEnterprise::EventLogger.info('user_invite', current_user.id, 'User invited', user, {user_email: user.email, account_name: @organization.name})

      @user = user.confirmed? ? invite : user.load_required

      render 'mno_enterprise/jpi/v1/admin/organizations/invite_member'
    end

    private

    # Invite for unconfirmed users are automatically accepted
    def find_org_invite(organization, user)
      if user.confirmed?
        status_scope = { 'status.in': 'staged,pending' }
      else
        status_scope = { status: 'accepted' }
      end
      MnoEnterprise::OrgaInvite.includes(:user, :organization, :team, :referrer).where(status_scope.merge(user_id: user.id, organization_id: organization.id)).first
    end

    # Send the org invite and update the status
    def send_org_invite(invite)
      user = invite.user
      # Generate token if not generated
      user.send(:generate_confirmation_token!) if !user.confirmed? && user.confirmation_token.blank?

      MnoEnterprise::SystemNotificationMailer.organization_invite(invite).deliver_now

      # Update staged invite status
      return unless invite.status == 'staged'
      invite.status = 'pending'
      invite.save
    end
  end
end
