module MnoEnterprise
  module MailAdapters
    # @abstract Subclass and override {#client} and {#deliver} to implement
    #   a custom Mailer Adapter.
    class Adapter
      class << self
        # Store the list of emails that are pending to be sent.
        # @note Only used for testing
        #
        # @example
        #   expect { some_action }.to change(Adapter.base_deliveries,:count).by(1)
        #
        # @return [Array]
        def base_deliveries
          @base_deliveries ||= []
        end

        # Check whether mailers are in test mode or not.
        # Emails should not be sent in test mode.
        #
        # @return [Boolean]
        def test?
          (Rails.configuration.action_mailer.delivery_method || '').to_sym == :test
        end

        def client
          raise NotImplementedError
        end

        # Send a template
        #
        # @param [String] template the immutable name of the template to send
        #
        # @param [Hash] from a hash describing the sender
        # @option from [String] :name optional from name to be used
        # @option from [String] :email the sender email address
        #
        # @param [Array, Hash] to an array or hash describing the recipient
        # @option to [String] :name optional recipient name
        # @option to [String] :email the recipient email address
        #
        # @param [Hash] vars substitution variables
        # @param [Hash] opts additional parameters to pass to the client
        #
        def deliver(template,from,to,vars = {},opts = {})
          raise NotImplementedError
        end
      end
    end
  end
end
