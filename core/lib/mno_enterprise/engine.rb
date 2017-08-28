module MnoEnterprise
  class Engine < ::Rails::Engine
    isolate_namespace MnoEnterprise

    # Autoload all files and sub-directories in
    # lib
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Autoload all translations from config/locales/**/*.yml
    initializer "mnoe.load_locales" do |app|
      # Engine:
      app.config.i18n.load_path += Dir[config.root.join('config', 'locales', '**/*.yml').to_s]

      # Host app:
      app.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**/*.yml').to_s]

      app.config.i18n.default_locale = :en

      # Add locales fallback
      # fr_CH => fr => en (default)
      require "i18n/backend/fallbacks"
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    end

    # Remove testing support when not in test
    unless Rails.env.test?
      path_rejector = lambda { |s| s.include?('/testing_support/') }
      config.autoload_paths.reject!(&path_rejector)
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    # Allow class overriding using decorator pattern
    # See: http://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

    # Add responding to JSON to Devise
    config.to_prepare do
      DeviseController.respond_to :html, :json
    end

    # Use memory store
    config.before_configuration do
      ::Rails.configuration.cache_store = :memory_store, { size: 32.megabytes }
    end

    # Configure the mailer default host
    config.before_initialize do
      if ENV['mailer_default_host'].present?
        opts = {
          host: ENV['mailer_default_host'],
          protocol: ENV['mailer_default_protocol'].presence || 'https'
        }
        config.action_mailer.default_url_options = opts
        config.action_mailer.asset_host = opts[:protocol] + '://' + opts[:host]
      end
    end

    # Enable ActionController caching
    config.before_initialize do
      Rails.application.config.action_controller.perform_caching = true
    end

    # Make sure the MailAdapter is correctly configured
    config.to_prepare do
      MnoEnterprise::MailClient.adapter ||= MnoEnterprise.mail_adapter
      MnoEnterprise::SystemManager.adapter ||= MnoEnterprise.platform_adapter
    end

    config.after_initialize do
      unless Rails.env.test? || File.basename($0) == "rake"
        Rails.logger.debug "Settings loaded -> Fetching Tenant Config"
        MnoEnterprise::TenantConfig.load_config!
      end
    end
  end
end
