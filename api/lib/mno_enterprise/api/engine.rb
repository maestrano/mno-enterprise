module MnoEnterprise
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise
      # To be able to load lib/mno_enterprise/concerns/...
      config.autoload_paths += Dir["#{config.root}/lib/**/"]

      # Add assets
      config.assets.precompile += %w( mno_enterprise/application_lib.js )
    end
  end
end
