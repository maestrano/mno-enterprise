# frozen_string_literal: true

# gem 'nex_client'
# require 'nex_client'
# SELF_NEX_API_KEY="some-api-key"
# SELF_NEX_API_ENDPOINT="https://api-nex-uat.maestrano.io"

module MnoEnterprise
  module PlatformAdapters
    # Nex!™ Adapter for MnoEnterprise::PlatformClient
    class NexAdapter < Adapter
      class << self
        # Restart the app
        def restart
          #TODO: implement
          raise NotImplementedError
        end
      end
    end
  end
end
