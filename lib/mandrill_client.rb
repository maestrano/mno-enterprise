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
  end
  
end