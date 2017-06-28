module MnoEnterprise
  # Abstract the app management logic
  #
  class SystemManager
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

    # @see MnoEnterprise::PlatformAdapters::Adapter#restart
    def self.restart
      adapter.restart
    end

    # @see MnoEnterprise::PlatformAdapters::Adapter#fetch_assets
    def self.fetch_assets
      adapter.fetch_assets
    end

    # @see MnoEnterprise::PlatformAdapters::Adapter#publish_assets
    def self.publish_assets
      adapter.publish_assets
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
