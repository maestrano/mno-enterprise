module MnoEnterprise
  class SystemNotificationMailer < ActionMailer::Base
    helper :application
    DEFAULT_SENDER = { name: MnoEnterprise.default_sender_name, email: MnoEnterprise.default_sender_email }
    
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
      MandrillClient.deliver(template,
        DEFAULT_SENDER,
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
      MandrillClient.deliver('reset-password-instructions',
        DEFAULT_SENDER,
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
      MandrillClient.deliver('unlock-instructions',
        DEFAULT_SENDER,
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
      
      MandrillClient.deliver(email_template,
        DEFAULT_SENDER,
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
      MandrillClient.deliver('deletion-request-instructions',
        DEFAULT_SENDER,
        recipient(record),
        user_vars(record).merge(terminate_account_link: deletion_request_url(deletion_request))
      )
    end

    protected
      def recipient(record, new_user = false)
        hash = { email: record.email }
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
end
