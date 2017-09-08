require 'action_mailer/railtie'

module MnoEnterprise
  # Base class (instantiable) for SMTP adapter
  class SmtpClient < ActionMailer::Base
    # Send SMTP template - terminal mailing part
    def deliver(template, from, to, vars={}, opts={})
      @info = vars
      @info[:company] = from[:name]
  
      for attachment in @info[:attachments]
        attachments[attachment[:name]] = attachment[:value]
      end if @info[:attachments]

      mail(
        from: format_sender(from),
        to: to[:email],
        subject: humanize(template),
        template_path: 'system_notifications',
        template_name: template
      )
    end 

    # Returns Actionmailer-compliant :from string
    # @Format : "Sender name <sender@email.com>"
    def format_sender(from)
      "#{from[:name]} <#{from[:email]}>"
    end
    
    # Returns humanized template subject
    # @i.e. "reset-password-instructions" to "Reset password instructions"
    def humanize(template_slug)
      template_slug.tr("-", "_").humanize
    end
  end
end
