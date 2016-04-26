# An interface to the Mandrill API
# @example
#   MandrillClient.send_template(template_name(string), template_content(array), message(hash))
# @deprecated Please use {MnoEnterprise::MailClient}
module MandrillClient
  class << self
    # Return a mandrill client configured with the right API key
    # @deprecated Use MnoEnterprise::MailClient
    def client
      @client ||= Mandrill::API.new(MnoEnterprise.mandrill_key)
    end
    
    # Send the provided template with options
    #
    # @example MandrillClient.send_template(template_name(string), template_content(array), message(hash))
    # @deprecated Use MnoEnterprise::MailClient
    def send_template(*args)
      warn '[DEPRECATION] `MandrillClient` is deprecated. Please use `MnoEnterprise::MailClient` instead.'
      MnoEnterprise::MailClient.adapter.send_template(*args)
    end
    
    # A simpler version of send_template
    #
    # @deprecated Use MnoEnterprise::MailClient
    def deliver(template,from,to,vars = {},opts = {})
      warn '[DEPRECATION] `MandrillClient` is deprecated. Please use `MnoEnterprise::MailClient` instead.'
      MnoEnterprise::MailClient.deliver(template,from,to,vars,opts)
    end
  end
end
