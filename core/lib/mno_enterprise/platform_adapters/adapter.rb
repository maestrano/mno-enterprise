# frozen_string_literal: true
module MnoEnterprise
  module PlatformAdapters
    # @abstract Subclass and override {#restart} and {#deliver} to implement
    #   a custom Platform Adapter.
    class Adapter
      class << self
        def restart
          raise NotImplementedError
        end

        def add_ssl_certs(_)
          raise NotImplementedError
        end
      end
    end
  end
end
