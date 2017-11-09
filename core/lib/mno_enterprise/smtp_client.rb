require 'action_mailer/railtie'

module MnoEnterprise
  # Base class (instantiable) for SMTP adapter
  class SmtpClient < ActionMailer::Base
    helper MnoEnterprise::ImageHelper
    
    # Send SMTP template - terminal mailing part
    def deliver(template, from, to, vars={}, opts={})
      @info = vars
      @info[:company] = from[:name]
      subject = opts[:subject] || humanize(template)
      mail(
        from: format_sender(from),
        to: to[:email],
        subject: subject,
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
