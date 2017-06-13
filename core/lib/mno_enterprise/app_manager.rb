module MnoEnterprise
  # Abstract the app management logic
  #
  class AppManager
    cattr_reader(:adapter)

    # Specify the platform adapter. The default platform adapter is the :local adapter.
    def self.adapter=(name_or_adapter)
      @@adapter = \
        case name_or_adapter
        when Symbol, String
          load_adapter(name_or_adapter)
        else
          name_or_adapter if name_or_adapter.respond_to?(:restart)
        end
    end

    # @see Adapter#restart
    def self.restart
      adapter.restart
    end

    # @see Adapter#add_ssl_certs
    def self.add_ssl_certs(*args)
      adapter.add_ssl_certs(*args)
    end

    private
    def self.load_adapter(name)
      "MnoEnterprise::PlatformAdapters::#{name.to_s.camelize}Adapter".constantize
    end
  end
end
