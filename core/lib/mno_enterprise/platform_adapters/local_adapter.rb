# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # Local Adapter for MnoEnterprise::PlatformClient
    class LocalAdapter < Adapter
      class << self
        # @see MnoEnterprise::PlatformAdapters::Adapter#restart
        def restart
          FileUtils.touch('tmp/restart.txt')
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#publish_assets
        def publish_assets
          # NOOP
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#fetch_assets
        def fetch_assets
          # NOOP
        end
      end
    end
  end
end
