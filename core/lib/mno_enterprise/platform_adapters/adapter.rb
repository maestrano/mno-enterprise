# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # @abstract Subclass and override methods to implement
    #   a custom Platform Adapter.
    class Adapter
      class << self
        # Restart the MnoEnterprise App
        def restart
          raise NotImplementedError
        end

        # Publish frontend assets to the persistence layer
        # Used by the ThemeController
        def publish_assets
          raise NotImplementedError
        end

        # Fetch frontend assets from the persistence layer
        # Used externally by the platform
        def fetch_assets
          raise NotImplementedError
        end

        def add_ssl_certs(_)
          raise NotImplementedError
        end
      end
    end
  end
end
