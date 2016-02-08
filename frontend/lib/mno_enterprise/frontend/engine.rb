module MnoEnterprise
  module Frontend
    class Engine < ::Rails::Engine
      isolate_namespace MnoEnterprise

      # Add assets
      config.assets.precompile += %w( mno_enterprise/application_lib.js )

      # To be able to load lib/mno_enterprise/concerns/...
      config.autoload_paths += Dir["#{config.root}/lib/**/"]

      # I18n management
      # Internally rewrite /en/dashboard/#/apps to /dashboard/#/apps
      if MnoEnterprise.i18n_enabled && (Rails.env.development? || Rails.env.test?)
        require 'rack-rewrite'

        initializer "mnoe.middleware" do |app|
          app.middleware.insert_before(0, Rack::Rewrite) do
            rewrite %r{/[a-z]{2}/dashboard/(.*)}, '/dashboard/$1'
          end
        end
      end
    end
  end
end
