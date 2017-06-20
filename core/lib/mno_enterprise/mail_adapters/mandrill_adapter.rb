gem 'mandrill-api', '~> 1.0.53'
require 'mandrill'

module MnoEnterprise
  module MailAdapters
    class MandrillAdapter < Adapter
      class << self
        # Return a mandrill client configured with the right API key
        def client
          @client ||= Mandrill::API.new(ENV['MANDRILL_API_KEY'])
        end

        # Send a template
        # @see Adapter#deliver
        def deliver(template, from, to, vars={}, opts={})
          # Prepare message from args
          message = { from_name: from[:name], from_email: from[:email]}
          message[:to] = [to].flatten.map { |t| {name: t[:name], email: t[:email], type: (t[:type] || :to) } }

          # Sanitize merge vars
          full_sanitizer = Rails::Html::FullSanitizer.new
          message[:global_merge_vars] = vars.map { |k,v| {name: k.to_s, content: full_sanitizer.sanitize(v)} }

          # Merge additional mandrill options
          message.merge!(opts)

          self.send_template(template,[],message)
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
  end
end
