MnoEnterprise.configure do |config|

  #===============================================
  # General Configuration
  #===============================================
  # Name of your company/application
  config.app_name = "Enterprise Demo"

  # Fallback default country.
  # Used as default in geolocalised fields (e.g.: country, phone number)
  config.app_country = 'US'

  # Fallback default currency.
  config.app_currency = 'USD'

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
  # External Routes
  #===============================================
  # URL of the Terms and Conditions page.
  # Used on Devise Registration pages
  config.router.terms_url = '#'

  #===============================================
  # Third Party Plugins
  #===============================================
  # Google Tag Manager
  # config.google_tag_container = nil

  #===============================================
  # API Configuration
  #===============================================
  # ==> Maestrano Enterprise API Configuration
  # Configure the API host and root path
  config.mno_api_host = "http://localhost:3000"

  # Configure the API root path
  config.mno_api_root_path = "/api/mnoe/v1"

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
