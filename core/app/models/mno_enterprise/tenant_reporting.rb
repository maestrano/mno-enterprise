module MnoEnterprise
  class TenantReporting < BaseResource
    # == Attributes ===========================================================

    # No primary key required here as this class is designed to hit the /tenant
    # (singular resource) endpoint.
    # We cannot put `nil` as jsonapi-client build the url with `attributes[:primary_key]`
    self.primary_key = :no_primary_key

    # == Class Methods ========================================================

    # This is a singleton resource
    def self.table_name
      'tenant_reporting'
    end

    def self.show
      self.find.first
    end
  end
end
