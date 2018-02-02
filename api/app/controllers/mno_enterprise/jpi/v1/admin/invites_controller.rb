module MnoEnterprise::Jpi::V1::Admin
  # Manage invitation sending
  class InvitesController < BaseResourceController
    def create
      @organization = MnoEnterprise::Organization.find(params[:organization_id])
      user = MnoEnterprise::User.find(params[:user_id])
      return render json: {error: 'Could not find account or user'}, status: :not_found unless @organization && user

      invite = find_org_invite(@organization, user)
      return render json: {error: 'No active invitation found'}, status: :not_found unless invite
      send_org_invite(user, invite)

      MnoEnterprise::EventLogger.info('user_invite', current_user.id, 'User invited', user, {user_email: user.email, account_name: @organization.name})

      @user = user.confirmed? ? invite : user.reload

      render 'mno_enterprise/jpi/v1/admin/organizations/invite_member'
    end

    private

    def find_org_invite(organization, user)
      status_scope = { 'status.in' => %w(staged pending accepted) }
      organization.org_invites.where(status_scope.merge(user_id: user.id)).first
    end

    # Send the org invite and update the status
    def send_org_invite(user, invite)
      # Generate token if not generated
      user.send(:generate_confirmation_token!) if !user.confirmed? && user.confirmation_token.blank?

      MnoEnterprise::SystemNotificationMailer.organization_invite(invite).deliver_later

      # Update staged invite status
      invite.status = 'pending' if invite.status == 'staged'
      invite.notification_sent_at = Time.now unless invite.notification_sent_at.present?
      invite.save
    end
  end
end
