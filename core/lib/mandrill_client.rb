# An interface to the Mandrill API
# Example usage:
# MandrillClient.send_template(template_name(string), template_content(array), message(hash))
module MandrillClient
  class << self
    
    # Store the list of mandrill emails that are pending
    # to be sent
    # Only used for testing
    # E.g: expect { some_action }.to change(MandrillClient.base_deliveries,:count).by(1)
    def base_deliveries
      @base_deliveries ||= []
    end
    
    # Check whether mailers are in test mode or not
    # Emails should not be sent in test mode
    def test?
      (Rails.configuration.action_mailer.delivery_method || '').to_sym == :test
    end
    
    # Return a mandrill client configured with the right API key
    def client
      @client ||= Mandrill::API.new(MnoEnterprise.mandrill_key)
    end
    
    # Send the provided template with options
    # MandrillClient.send_template(template_name(string), template_content(array), message(hash))
    def send_template(*args)
      if self.test?
        self.base_deliveries.push(args)
      else
        self.client.messages.send_template(*args)
      end
    end
    
    # A simpler version of send_template
    #
    # Take in argument:
    #   template: name of a mandrill template
    #   from: hash describing the sender. E.g.: { name: "John", email: "john.doe@maestrano.com" }
    #   to: Array or hash describing the recipient. E.g.: { name: "Jack", email: "jack.doe@maestrano.com" }
    #   vars: Mandrill email variables. E.g.: { link: "https://mywebsite.com/confirm_account" }
    #   opts: additional parameters to pass to mandrill. See: https://mandrillapp.com/api/docs/messages.ruby.html
    #
    def deliver(template,from,to,vars = {},opts = {})
      # Prepare message from args
      message = { from_name: from[:name], from_email: from[:email]}
      message[:to] = [to].flatten.map { |t| {name: t[:name], email: t[:email], type: (t[:type] || :to) } }
      message[:global_merge_vars] = vars.map { |k,v| {name: k.to_s, content: v} }
      
      # Merge additional mandrill options
      message.merge!(opts)
      
      self.send_template(template,[],message)
    end
  end
  
end