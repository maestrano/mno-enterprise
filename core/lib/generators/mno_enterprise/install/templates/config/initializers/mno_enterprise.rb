# require 'mno-enterprise'

MnoEnterprise.configure do |config|
  #===============================================
  # General Configuration
  #===============================================
  # Name of your company/application
  config.app_name = "My Company"

  # Fallback default country.
  # Used as default in geolocalised fields (e.g.: country, phone number)
  # config.app_country = 'US'

  # Fallback default currency.
  # config.app_currency = 'USD'

  #===============================================
  # Maestrano Enterprise Tenant Authentication
  #===============================================
  # Configure your tenant ID
  config.tenant_id = "my_tenant_id"

  # Configure your tenant Key
  config.tenant_key = "my_tenant_access_key"

  #===============================================
  # Emailing
  #===============================================
  # Mandrill API key for sending email
  # Defaulted to Maestrano Enterprise demo account
  # config.mandrill_key = 'some-mandrill-api-key'

  # Support email address
  config.support_email = 'support@example.com'

  # Default sender for system generated emails
  config.default_sender_name = 'My Company'
  config.default_sender_email = 'no-reply@example.com'

  #===============================================
  # External Routes
  #===============================================
  # URL of the Terms and Conditions page.
  # Used on Devise Registration pages
  # config.router.terms_url = 'http://mywebsite.com/terms'

  #===============================================
  # Optional Modules
  #===============================================
  # Angular CSRF protection - Only needed if the AngularJS App
  # is not served through Rails asset pipeline
  # config.include_angular_csrf = false

  #===============================================
  # Third Party Plugins
  #===============================================
  # Google Tag Manager
  # config.google_tag_container = nil

  #===============================================
  # API Configuration
  #===============================================
  # ==> Maestrano Enterprise API Configuration
  # Configure the API host
  # config.mno_api_host = "https://api-enterprise.maestrano.com"

  # Configure the API root path
  # config.mno_api_root_path = "/v1"

  #===============================================
  # Impac! Reporting Configuration
  #===============================================
  # ==> Impac! API Configuration
  # Configure the API host
  # config.impac_api_host = "https://api-impac-uat.maestrano.io"

  # Configure the API root path
  # config.impac_api_root_path = "/api/v1"

  #===============================================
  # Marketplace Listing
  #===============================================
  # config.marketplace_listing = [
  #   "allocpsa",
  #   "bugzilla",
  #   "collabtive",
  #   "dolibarr",
  #   "drupal",
  #   "egroupware",
  #   "eventbrite",
  #   "feng-office",
  #   "front-accounting",
  #   "group-office",
  #   "hummingbirdshare",
  #   "interleave",
  #   "jenkins",
  #   "joomla",
  #   "limesurvey",
  #   "mantisbt",
  #   "megaventory",
  #   "moodle",
  #   "myob",
  #   "office-365",
  #   "opendocman",
  #   "openerp",
  #   "openx",
  #   "orangehrm",
  #   "pentaho-bi",
  #   "phreedom",
  #   "plandora",
  #   "prestashop",
  #   "processmaker",
  #   "projectpier",
  #   "quickbooks",
  #   "receipt-bank",
  #   "signmee",
  #   "simpleinvoices",
  #   "so-planning",
  #   "spotlight-reporting",
  #   "sugarcrm",
  #   "timetrex",
  #   "vtiger6",
  #   "wordpress"
  # ]
end
