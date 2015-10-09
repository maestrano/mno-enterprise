module MnoEnterprise
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise
      # To be able to load lib/mno_enterprise/concerns/...
      config.autoload_paths += Dir["#{config.root}/lib/**/"]
    end
  end
end
