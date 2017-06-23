module MnoEnterprise
  class TenantReporting < BaseResource
    # == Class Methods ========================================================

    # jsonapi-client build the url with attributes[:primary_key]
    self.primary_key = :no_primary_key
    # This is a singleton resource
    def self.table_name
      'tenant_reporting'
    end
    def self.show
      self.find.first
    end
  end
end
