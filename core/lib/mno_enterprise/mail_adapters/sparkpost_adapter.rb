gem 'sparkpost'
require 'sparkpost'

module MnoEnterprise
  module MailAdapters
    # SparkPost Adapter for MnoEnterprise::MailClient
    class SparkpostAdapter < Adapter
      class << self
        # Return a sparkpost client configured with the right API key
        # api key is set in ENV through ENV['SPARKPOST_API_KEY']
        # @return [SparkPost::Client]
        def client
          @client ||= SparkPost::Client.new
        end

        # Send a template
        # @see Adapter#deliver
        def deliver(template, from, to, vars={}, opts={})
          # Prepare message from args
          message = {
            recipients: prepare_recipients(to),
            content: {
              from: from,
              template_id: template
            },
            substitution_data: vars
          }

          # Merge additional options
          message.merge!(opts)

          # Send
          send_template(template,[],message)
        end

        # Send the provided template with options
        # SparkpostClient.send_template(template_name(string), template_content(array), message(hash))
        def send_template(template_name, _, message)
          if test?
            base_deliveries.push([template_name, message])
          else
            message[:content][:template_id] = template_name
            client.transmission.send_payload(message)
          end
        end

        private

        # TODO: Use delegate?
        def prepare_recipients(recipients)
          client.transmission.prepare_recipients(recipients)
        end
      end
    end
  end
end
