module MnoEnterprise::Concerns::Mailers::SystemNotificationMailer
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    helper :application
    DEFAULT_SENDER = { name: MnoEnterprise.default_sender_name, email: MnoEnterprise.default_sender_email }
  end

  #==================================================================
  # Instance methods
  #==================================================================

  # Default email sender
  # Override to allow dynamic sender
  def default_sender
    DEFAULT_SENDER
  end

  # ==> Devise Email
  # Description:
  #   Email asking users to confirm their email
  #
  # Mandrill vars:
  #   :first_name
  #   :last_name
  #   :full_name
  #   :confirmation_link
  #
  def confirmation_instructions(record, token, opts={})
    template = record.confirmed? && record.unconfirmed_email? ? 'reconfirmation-instructions' : 'confirmation-instructions'
    MnoEnterprise::MailClient.deliver(template,
      default_sender,
      recipient(record),
      user_vars(record).merge(confirmation_link: user_confirmation_url(confirmation_token: token))
    )
  end

  # ==> Devise Email
  # Description:
  #   Email providing instructions + link to reset password
  #
  # Mandrill vars:
  #   :first_name
  #   :last_name
  #   :full_name
  #   :reset_password_link
  #
  def reset_password_instructions(record, token, opts={})
    MnoEnterprise::MailClient.deliver('reset-password-instructions',
      default_sender,
      recipient(record),
      user_vars(record).merge(reset_password_link: edit_user_password_url(reset_password_token: token))
    )
  end

  # ==> Devise Email
  # Description:
  #   Email providing instructions + link to unlock a user account after too many failed attempts
  #
  # Mandrill vars:
  #   :first_name
  #   :last_name
  #   :full_name
  #   :unlock_link
  #
  def unlock_instructions(record, token, opts={})
    MnoEnterprise::MailClient.deliver('unlock-instructions',
      default_sender,
      recipient(record),
      user_vars(record).merge(unlock_link: user_unlock_url(unlock_token: token))
    )
  end

  # Description:
  #   Send an email inviting the user to join an existing organization. If the user
  #   is already confirmed it is directed to the organization invite page where he
  #   can accept or decline the invite
  #   If the user is not confirmed yet then it is considered a new user and will be directed
  #   to the confirmation page
  #
  # Mandrill vars:
  #   :organization
  #   :team
  #   :ref_first_name
  #   :ref_last_name
  #   :ref_full_name
  #   :ref_email
  #   :invitee_first_name
  #   :invitee_last_name
  #   :invitee_full_name
  #   :invitee_email
  #   :confirmation_link
  #
  def organization_invite(org_invite)
    new_user = !org_invite.user.confirmed?
    confirmation_link = new_user ? user_confirmation_url(confirmation_token: org_invite.user.confirmation_token) : org_invite_url(org_invite, token: org_invite.token)
    email_template = new_user ? 'organization-invite-new-user' : 'organization-invite-existing-user'

    MnoEnterprise::MailClient.deliver(email_template,
      default_sender,
      recipient(org_invite.user,new_user),
      invite_vars(org_invite,new_user).merge(confirmation_link: confirmation_link)
    )
  end

  # Description:
  #   Email providing instructions + link to initiate the account termination
  #   process.
  #
  # Mandrill vars:
  #   :first_name
  #   :last_name
  #   :full_name
  #   :terminate_account_link
  def deletion_request_instructions(record, deletion_request)
    MnoEnterprise::MailClient.deliver('deletion-request-instructions',
      default_sender,
      recipient(record),
      user_vars(record).merge(terminate_account_link: deletion_request_url(deletion_request))
    )
  end

  # Description:
  #   Email providing registration instructions
  #
  # Variables:
  #   :registration_link
  def registration_instructions(email)
    MnoEnterprise::MailClient.deliver(
      'registration-instructions',
      default_sender,
      {email: email},
      {registration_link: new_user_registration_url}
    )
  end

  protected

  def recipient(record, new_user = false)
    # Org Invite for unconfirmed users will have the email in #unconfirmed_email
    hash = { email: record.email || record.unconfirmed_email }
    hash[:name] = "#{record.name} #{record.surname}".strip unless new_user
    hash
  end

  def user_vars(record)
    {
      first_name: record.name,
      last_name: record.surname,
      full_name: "#{record.name} #{record.surname}".strip
    }
  end

  def invite_vars(org_invite, new_user = true)
    {
      organization: org_invite.organization.name,
      team: org_invite.team.present? ? org_invite.team.name : nil,
      ref_first_name: org_invite.referrer.name,
      ref_last_name: org_invite.referrer.surname,
      ref_full_name: "#{org_invite.referrer.name} #{org_invite.referrer.surname}".strip,
      ref_email: org_invite.referrer.email,
      invitee_first_name: new_user ? nil : org_invite.user.name,
      invitee_last_name: new_user ? nil : org_invite.user.surname,
      invitee_full_name: new_user ? nil : "#{org_invite.user.name} #{org_invite.user.surname}".strip,
      invitee_email: org_invite.user.email,
    }
  end
end
