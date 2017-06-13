# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # Local Adapter for MnoEnterprise::PlatformClient
    class LocalAdapter < Adapter
      class << self
        # Restart the app
        def restart
          FileUtils.touch('tmp/restart.txt')
        end
      end
    end
  end
end
