# frozen_string_literal: true
module MnoEnterprise
  # Frontend configuration management
  class TenantConfig
    # == Constants ============================================================
    # See core/config/initializers/00_tenant_config_schema.rb for the configuration
    # JSON schema.
    # This file *MUST* be updated any time a new feature flag is added
    CACHE_KEY = 'mnoe/tenant-config/minified'

    # == Extensions ===========================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    # @return [Hash] Config JSON Schema
    def self.json_schema
      MnoEnterprise::CONFIG_JSON_SCHEMA
    end

    # Return a config Hash with the default values based on the schema
    # @return [Hash] Config hash
    def self.to_hash
      build_object(json_schema)
    end

    # Render a YAML representation of the config
    # Mostly used for debugging purppose
    # @return [String] YAML representation of the config
    def self.to_yaml
      to_hash.to_yaml
    end

    # Load the Tenant#frontend_config from MnoHub and add it to the settings
    #
    #  TODO: include retry/caching/...
    def self.load_config!
      return unless (frontend_config = fetch_tenant_config)

      # Merge the settings and reload
      Settings.add_source!(frontend_config)
      Settings.reload!

      # Reconfigure mnoe
      reconfigure_mnoe!

      # TODO: update JSON_SCHEMA with readonly fields
      refresh_json_schema!

      # # Save settings in YAML format for easy debugging
      # Rails.logger.debug "Settings loaded -> Saving..."
      # File.open(Rails.root.join('tmp', 'cache', 'settings.yml'), 'w') do |f|
      #   f.write(Settings.to_hash.deep_stringify_keys.to_yaml)
      # end

      Rails.cache.delete(CACHE_KEY)
    end

    # Reconfigure Mnoe settings that were set during initialization
    def self.reconfigure_mnoe!
      MnoEnterprise.configure do |config|
        config.app_name = Settings.system.app_name

        # Emailing
        config.support_email = Settings.system.email.support_email
        config.default_sender_name = Settings.system.email.default_sender.name
        config.default_sender_email = Settings.system.email.default_sender.email

        # I18n
        config.i18n_enabled = Settings.system.i18n.enabled
      end
      Rails.application.config.action_mailer.smtp_settings = Settings.system.smtp.to_hash
      ActionMailer::Base.smtp_settings = Settings.system.smtp.to_hash
    end

    # Update the JSON schema with values available after initialization
    # TODO: Refactor to use Proc in the JSON Schema and call them
    def self.refresh_json_schema!
      # Re-evaluate the availables locales as the list is only populated after initialization
      available_locales = I18n.available_locales.map(&:to_s).select {|x| x =~ /[[:alpha:]]{2}-[A-Z]{2}/}
      locale_map = Hash[available_locales.map {|l| [l, I18n.t('language', locale: l, fallback: false, default: nil) || l] }]

      json_schema['properties']['system']['properties']['i18n']['properties']['available_locales']['items']['enum'] = available_locales
      json_schema['properties']['system']['properties']['i18n']['properties']['preferred_locale']['enum'] = available_locales
      json_schema['properties']['system']['properties']['i18n']['properties']['available_locales']['x-schema-form']['titleMap'] = locale_map
      json_schema['properties']['system']['properties']['i18n']['properties']['preferred_locale']['x-schema-form']['titleMap'] = locale_map
    end

    # Fetch the Tenant#frontend_config from MnoHub
    #
    # @return [Hash] Tenant configuration
    def self.fetch_tenant_config
      MnoEnterprise::Tenant.show.frontend_config
    rescue JsonApiClient::Errors::ConnectionError
      Rails.logger.warn "Couldn't get configuration from MnoHub"
      puts "Couldn't get configuration from MnoHub"
    end

    # Convert JSON Schema to hash with default value
    #
    # @param [Hash] schema JSON schema to parse
    def self.build_object(schema)
      case schema['type']
      when 'string', 'integer', 'boolean', 'password'
        schema['default']
      when 'object'
        h = {}
        schema['properties'].each do |k, inner_schema|
          h[k] = build_object(inner_schema)
        end
        h.compact
      end
    end
  end
end
