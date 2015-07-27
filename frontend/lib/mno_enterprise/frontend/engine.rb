module MnoEnterprise
  module Frontend
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise

      # Add assets
      config.assets.precompile += %w( mno_enterprise/application_lib.js )
    end
  end
end
