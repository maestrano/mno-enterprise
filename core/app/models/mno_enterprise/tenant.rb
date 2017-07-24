module MnoEnterprise
  class Tenant < BaseResource
    # == Attributes ===========================================================
    property :created_at, type: :time
    property :updated_at, type: :time
    property :frontend_config

    # No primary key required here as this class is designed to hit the /tenant
    # (singular resource) endpoint.
    # We cannot put `nil` as jsonapi-client build the url with `attributes[:primary_key]`
    self.primary_key = :no_primary_key

    # == Extensions ===========================================================

    # == Relationships ========================================================

    # == Validations ==========================================================
    validate :must_match_json_schema

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

    private

    # Validates frontend_config against the JSON Schema
    def must_match_json_schema
      json_errors = JSON::Validator.fully_validate(MnoEnterprise::TenantConfig.json_schema, frontend_config)
      json_errors.each do |error|
        errors.add(:frontend_config, error)
      end
    end
  end
end
