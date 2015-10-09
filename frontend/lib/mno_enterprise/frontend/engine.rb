module MnoEnterprise
  module Frontend
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise

      # Add assets
      config.assets.precompile += %w( mno_enterprise/application_lib.js )

      # To be able to load lib/mno_enterprise/concerns/...
      config.autoload_paths += Dir["#{config.root}/lib/**/"]
    end
  end
end
