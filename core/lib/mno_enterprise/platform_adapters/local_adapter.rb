# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # Local Adapter for MnoEnterprise::PlatformClient
    class LocalAdapter < Adapter
      class << self
        # @see MnoEnterprise::PlatformAdapters::Adapter#restart
        def restart(timestamp = nil)
          FileUtils.touch('tmp/restart.txt')
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#restart_status
        def restart_status
          'success'
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#publish_assets
        def publish_assets
          # NOOP
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#fetch_assets
        def fetch_assets
          # NOOP
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#update_domain
        def update_domain(domain_name)
          # NOOP
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#add_ssl_certs
        def add_ssl_certs(cert_name, public_cert, cert_bundle, private_key)
          # NOOP
        end
      end
    end
  end
end
