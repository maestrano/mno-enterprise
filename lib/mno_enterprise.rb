require "mno_enterprise/engine"

module MnoEnterprise
  
  # The Maestrano Enterprise API Host
  mattr_accessor :mno_api_host
  @@mno_api_host = "https://api-enterprise.maestrano.com"
  
  # The Maestrano Enterprise API base path
  mattr_accessor :mno_api_root_path
  @@mno_api_root_path = "/v1"
  
  # Maestrano Enterprise Tenant ID
  mattr_accessor :tenant_id
  @@tenant_id = nil
  
  # Maestrano Enteprise Tenant Key
  mattr_accessor :tenant_key
  @@tenant_key = nil
  
  # Default way to setup MnoEnterprise. Run rails generate mno-enterprise:install to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield self
  end
end
