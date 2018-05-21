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

    class << self
      # @see MnoEnterprise::PlatformAdapters::Adapter#restart
      delegate :restart, to: :adapter

      # @see MnoEnterprise::PlatformAdapters::Adapter#restart_done?
      delegate :restart_status, to: :adapter

      # @see MnoEnterprise::PlatformAdapters::Adapter#clear_assets
      delegate :clear_assets, to: :adapter

      # @see MnoEnterprise::PlatformAdapters::Adapter#fetch_assets
      delegate :fetch_assets, to: :adapter

      # @see MnoEnterprise::PlatformAdapters::Adapter#publish_assets
      delegate :publish_assets, to: :adapter

      # @see MnoEnterprise::PlatformAdapters::Adapter#update_domain
      delegate :update_domain, to: :adapter

      # @see MnoEnterprise::PlatformAdapters::Adapter#add_ssl_certs
      delegate :add_ssl_certs, to: :adapter
    end

    private

    def self.load_adapter(name)
      "MnoEnterprise::PlatformAdapters::#{name.to_s.camelize}Adapter".constantize
    end
  end
end
