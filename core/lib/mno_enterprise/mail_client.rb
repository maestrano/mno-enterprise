module MnoEnterprise
  # Abstract the email sending logic
  #
  class MailClient
    cattr_reader(:adapter)

    # Specify the mail adapter. The default email adapter is the :mandrill adapter.
    def self.adapter=(name_or_adapter)
      @@adapter = \
        case name_or_adapter
        when Symbol, String
          load_adapter(name_or_adapter)
        else
          name_or_adapter if name_or_adapter.respond_to?(:deliver)
        end
    end

    # @see Adapter#deliver
    def self.deliver(*args)
      adapter.deliver(*args)
    end

    private
    def self.load_adapter(name)
      "MnoEnterprise::MailAdapters::#{name.to_s.camelize}Adapter".constantize
    end
  end
end
