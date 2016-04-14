module MnoEnterprise
  module MailAdapters
    # Test Adapter for MnoEnterprise::MailClient
    # Add messages to an internal array instead of sending them
    class TestAdapter < Adapter
      class << self
        # Send a template
        # @see Adapter#deliver
        def deliver(*args)
          send_template(*args)
        end

        # Send the provided template with options
        # SparkpostClient.send_template(template_name(string), template_content(array), message(hash))
        def send_template(*args)
          base_deliveries.push(*args)
        end
      end
    end
  end
end
