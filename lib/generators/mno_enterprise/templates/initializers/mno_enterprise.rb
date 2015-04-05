require 'mno-enterprise'

MnoEnterprise.configure do |config|
  
  # ==> Maestrano Enterprise Tenant Authentication
  # Configure your tenant ID
  config.tenant_id = "my_tenant_id"
  
  # Configure your tenant Key
  config.tenant_key = "my_tenant_access_key"
  
  # ==> Maestrano Enterprise API Configuration
  # Configure the API host and root path
  # config.mno_api_host = "https://api-enterprise.maestrano.com"
  
  # Configure the API root path
  # config.mno_api_root_path = "/v1"
  
end