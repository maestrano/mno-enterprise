module MnoEnterprise
  class Tenant < BaseResource
    # == Attributes ===========================================================
    property :created_at, type: :time
    property :updated_at, type: :time
    property :frontend_config
    property :keystore, type: :hash

    # No primary key required here as this class is designed to hit the /tenant
    # (singular resource) endpoint.
    # We cannot put `nil` as jsonapi-client build the url with `attributes[:primary_key]`
    self.primary_key = :no_primary_key

    # == Extensions ===========================================================

    # == Relationships ========================================================

    # == Validations ==========================================================
    validate :must_match_json_schema
    validate :validate_plugin_config

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    # This is a singleton resource
    def self.table_name
      'tenant'
    end

    def self.type
      'tenants'
    end

    def self.show
      self.find.first
    end

    # == Instance Methods =====================================================
    # Singleton resource
    # default is looking at primary_key.present
    def persisted?
      true
    end

    def plugins_config
      # TODO: dynamic config?
      @plugins_config ||= MnoEnterprise::Plugins::PaymentGateway.new(self, {}).show_config
    end

    def plugins_config=(config)
      @plugins_config = config
      config.each do |plugin_name, conf|
        plugin = "MnoEnterprise::Plugins::#{plugin_name.classify}".constantize.new(self, plugin_name => conf)
        plugin.save
      end
    end

    private

    def validate_plugin_config
      plugins_config.each do |plugin_name, conf|
        plugin = "MnoEnterprise::Plugins::#{plugin_name.classify}".constantize.new(self, plugin_name => conf)
        next if plugin.valid?

        plugin.errors[:config].each do |e|
          errors.add(:plugins_config, e)
        end
        return false
      end
    end

    # Validates frontend_config against the JSON Schema
    def must_match_json_schema
      json_errors = JSON::Validator.fully_validate(MnoEnterprise::TenantConfig.json_schema, frontend_config)
      json_errors.each do |error|
        errors.add(:frontend_config, error)
      end
    end
  end
end
