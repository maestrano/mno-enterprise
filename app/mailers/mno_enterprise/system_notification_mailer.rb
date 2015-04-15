module MnoEnterprise
  class SystemNotificationMailer < ActionMailer::Base
    helper :application
    DEFAULT_SENDER = { name: MnoEnterprise.default_sender_name, email: MnoEnterprise.default_sender_email }
    
    # Email asking users to confirm their email
    # Mandrill vars:
    #   :first_name
    #   :last_name
    #   :full_name
    #   :confirmation_link
    #
    def confirmation_instructions(record, token, opts={})
      puts "tamere"
      MandrillClient.deliver('confirmation-instructions',
        DEFAULT_SENDER,
        recipient(record),
        user_vars(record).merge(confirmation_link: user_confirmation_url(confirmation_token: token))
      )
    end
    
    # Email providing instructions + link to reset password
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
    
    # Email providing instructions + link to unlock a user account after too many failed attempts
    # Mandrill vars:
    #   :first_name
    #   :last_name
    #   :full_name
    #   :reset_password_link
    #
    def unlock_instructions(record, token, opts={})
      MandrillClient.deliver('unlock-instructions',
        DEFAULT_SENDER,
        recipient(record),
        user_vars(record).merge(unlock_link: user_unlock_url(unlock_token: token))
      )
    end
    
    protected
      def recipient(record)
        { name: "#{record.name} #{record.surname}".strip, email: record.email }
      end
      
      def user_vars(record)
        { 
          first_name: record.name,
          last_name: record.surname,
          full_name: "#{record.name} #{record.surname}".strip
        }
      end
  end
end
