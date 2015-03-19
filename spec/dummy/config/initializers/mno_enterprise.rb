MnoEnterprise.configure do |config|
  
  # ==> Maestrano Enterprise Tenant Authentication
  # Configure your tenant ID
  config.tenant_id = "ea461720-b044-0132-dba6-600308937d74"
  
  # Configure your tenant Key
  config.tenant_key = "dPhCSjZCJ68I2cQLzCBtTg"
  
  # ==> Maestrano Enterprise API Configuration
  # Configure the API host and root path
  config.mno_api_host = "http://localhost:3000"
  
  # Configure the API root path
  config.mno_api_root_path = "/api/mnoe/v1"
  
end