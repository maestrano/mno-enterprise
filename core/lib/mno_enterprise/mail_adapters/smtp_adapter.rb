module MnoEnterprise
  module MailAdapters
    # SMTP Adapter for MnoEnterprise::MailClient
    class SmtpAdapter < Adapter
      class << self
        # Return a smtp client configured with the SMTP settings
        # @return [SmtpClient]
        def client
          @client = MnoEnterprise::SmtpClient.send :new
        end

        # Send a template
        # @See Adapter#deliver
        def deliver(template, from, to, vars={}, opts={})
          client.deliver(template, from, to, vars, opts).deliver
        end

      end
    end
  end
end
