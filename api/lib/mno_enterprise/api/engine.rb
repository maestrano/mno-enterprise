module MnoEnterprise
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise
      # To be able to load lib/mno_enterprise/concerns/...
      config.autoload_paths += Dir["#{config.root}/lib/**/"]

      # Add assets
      if config.respond_to? (:assets)
        config.assets.precompile += %w( mno_enterprise/config.js mno_enterprise/error_page.js )

        # Allow sprockets to find file in the config/ path
        config.before_configuration do
          config.assets.paths.unshift Rails.root.join('config').to_s
        end
      end
    end
  end
end
