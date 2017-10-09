# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # Dummy test adapter for MnoEnterprise::PlatformClient
    # All methods are NOOP
    class TestAdapter < Adapter
      class << self
        # @see MnoEnterprise::PlatformAdapters::Adapter#restart
        def restart(timestamp = nil); end

        def restart_status
          'success'
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#publish_assets
        def publish_assets; end

        # @see MnoEnterprise::PlatformAdapters::Adapter#fetch_assets
        def fetch_assets; end

        # @see MnoEnterprise::PlatformAdapters::Adapter#update_domain
        def update_domain(*args)
          true
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#add_ssl_certs
        def add_ssl_certs(*args)
          true
        end
      end
    end
  end
end
