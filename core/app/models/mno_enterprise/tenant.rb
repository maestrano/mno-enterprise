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
  end
end
