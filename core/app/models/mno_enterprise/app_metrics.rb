module MnoEnterprise
  class AppMetrics < BaseResource
    # == Attributes ===========================================================

    # No primary key required here as this class is designed to hit the /app_metrics tenant endpoint.
    # We cannot put `nil` as jsonapi-client build the url with `attributes[:primary_key]`
    self.primary_key = :no_primary_key

    # == Class Methods ========================================================

    # This is a singleton resource
    def self.table_name
      'app_metrics'
    end

    def self.show
      self.find.first
    end
  end
end
