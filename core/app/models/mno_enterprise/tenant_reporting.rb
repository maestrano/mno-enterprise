module MnoEnterprise
  class TenantReporting < BaseResource
    # == Class Methods ========================================================

    # This is a singleton resource
    def self.table_name
      'tenant_reporting'
    end
  end
end
