module MnoEnterprise
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise
      # To be able to load lib/mno_enterprise/concerns/...
      config.autoload_paths += Dir["#{config.root}/lib/**/"]

      # Add assets
      if config.respond_to? (:assets)
        config.assets.precompile += %w( mno_enterprise/config.js )
      end
    end
  end
end
