MnoEnterprise.configure do |config|
    
  #===============================================
  # General Configuration
  #===============================================
  # Name of your company/application
  config.app_name = "Enterprise Demo"
  
  #===============================================
  # Maestrano Enterprise Tenant Authentication
  #===============================================
  # Configure your tenant ID
  config.tenant_id = "ea461720-b044-0132-dba6-600308937d74"
  
  # Configure your tenant Key
  config.tenant_key = "dPhCSjZCJ68I2cQLzCBtTg"
  
  #===============================================
  # Emailing
  #===============================================
  # Mandrill API key for sending email 
  # Defaulted to Maestrano Enterprise demo account
  # config.mandrill_key = 'some-mandrill-api-key'
  
  # Support email address
  config.support_email = 'support@enterprise-demo-mnoe.maestrano.io'
  
  # Default sender for system generated emails
  config.default_sender_name = 'Enterprise Demo'
  config.default_sender_email = 'no-reply@enterprise-demo-mnoe.maestrano.io'
  
  #===============================================
  # API Configuration
  #===============================================
  # ==> Maestrano Enterprise API Configuration
  # Configure the API host and root path
  config.mno_api_host = "http://localhost:3000"
  
  # Configure the API root path
  config.mno_api_root_path = "/api/mnoe/v1"
end