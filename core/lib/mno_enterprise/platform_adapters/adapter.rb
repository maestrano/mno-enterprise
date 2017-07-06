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

        # Update the domain of the webstore
        # @param [String] domain_name new domain for the webstore
        # @return [Object] return false in case of error
        def update_domain(domain_name)
          raise NotImplementedError
        end

        # Add SSL certificates to the webstore
        # @param [String] cert_name CNAME for the certificate
        # @param [String] public_cert Public certificate
        # @param [String] cert_bundle CA bundle
        # @param [String] private_key Certificate private key
        # @return [Object] return false in case of error
        def add_ssl_certs(cert_name, public_cert, cert_bundle, private_key)
          raise NotImplementedError
        end
      end
    end
  end
end
