# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # Test Adapter for MnoEnterprise::PlatformClient
    class TestAdapter < Adapter
      class << self
        def restart
        end
      end
    end
  end
end
