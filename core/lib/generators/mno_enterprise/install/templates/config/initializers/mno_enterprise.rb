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
  config.tenant_id = ENV['tenant_id']

  # Configure your tenant Key
  config.tenant_key = ENV['tenant_key']

  #===============================================
  # Emailing
  #===============================================
  # Mandrill API key for sending email
  # Defaulted to Maestrano Enterprise demo account
  # config.mandrill_key = 'some-mandrill-api-key'

  # Adapter used to send emails
  # Default to :mandrill
  # config.mail_adapter = :mandrill
  # config.mail_adapter = :sparkpost

  # Support email address
  config.support_email = 'support@example.com'

  # Default sender for system generated emails
  config.default_sender_name = 'My Company'
  config.default_sender_email = 'no-reply@example.com'

  #===============================================
  # External Routes
  #===============================================
  # Dashboard path
  # config.router.dashboard_path = '/dashboard/'

  # URL of the Terms and Conditions page.
  # Used on Devise Registration pages
  # config.router.terms_url = 'http://mywebsite.com/terms'

  # After sign out URL. Default to the root_path
  # config.router.after_sign_out_url = 'http://mywebsite.com/'

  #===============================================
  # Optional Modules
  #===============================================
  # Angular CSRF protection - Only needed if the AngularJS App
  # is not served through Rails asset pipeline
  config.include_angular_csrf = true

  # I18n - Controls:
  #   - Routing in development
  #   - Filter and locale management in controllers
  config.i18n_enabled = true

  #===============================================
  # Third Party Plugins
  #===============================================
  # Google Tag Manager
  config.google_tag_container = ENV['google_tag_container']

  #===============================================
  # API Configuration
  #===============================================
  # ==> Maestrano Enterprise API Configuration
  # Configure the API host
  # config.mno_api_host = "https://api-enterprise.maestrano.com"
  config.mno_api_host = "#{Settings.mno.protocol}://#{Settings.mno.host}"

  # Configure private API host if defined
  if Settings.mno.private_protocol && Settings.mno.private_host
    config.mno_api_private_host = "#{Settings.mno.private_protocol}://#{Settings.mno.private_host}"
  end

  # Configure the API root path
  # config.mno_api_root_path = "/v1"
  config.mno_api_root_path = Settings.mno.paths.root

  #===============================================
  # Marketplace Listing
  #===============================================
  # List of applications that should be offered on the marketplace
  # Set to nil to offer everything
  # config.marketplace_listing = nil
  # config.marketplace_listing = [
  #   "allocpsa",
  #   "boxsuite",
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
  #   "magento",
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
  #   "ranqx",
  #   "receipt-bank",
  #   "signmee",
  #   "simpleinvoices",
  #   "so-planning",
  #   "spotlight-reporting",
  #   "sugarcrm",
  #   "timetrex",
  #   "vtiger6",
  #   "xero",
  #   "wordpress"
  # ]

  #====================================
  # Impac! widgets templates listing
  #====================================
  # config.widgets_templates_listing = nil
  # config.widgets_templates_listing = [
  #   'accounts/balance',
  #   'accounts/comparison',
  #   'accounts/expenses_revenue',
  #   'accounts/payable_receivable',
  #   'accounts/assets_summary',
  #   'accounts/custom_calculation',
  #   'accounts/accounting_values/ebitda',
  #   'accounts/accounting_values/turnover',
  #   'accounts/accounting_values/workforce_costs',
  #   'accounts/accounting_values/payroll_taxes_account',
  #   'accounts/cash_summary',
  #   'accounts/balance_sheet',
  #   'accounts/profit_and_loss',
  #   'invoices/list',
  #   'invoices/summary',
  #   'invoices/aged_payables_receivables',
  #   'hr/workforce_summary',
  #   'hr/salaries_summary',
  #   'hr/employees_list',
  #   'hr/employee_details',
  #   'hr/payroll_taxes',
  #   'hr/superannuation_accruals',
  #   'hr/leaves_balance',
  #   'hr/payroll_summary',
  #   'hr/timesheets',
  #   'sales/summary',
  #   'sales/list',
  #   'sales/growth',
  #   'sales/segmented_turnover',
  #   'sales/customer_details',
  #   'sales/margin',
  #   'sales/aged',
  #   'sales/comparison',
  #   'sales/leads_list',
  #   'sales/number_of_leads',
  #   'sales/cycle',
  #   'sales/leads_funnel',
  #   'sales/opportunities_funnel',
  #   'sales/top_opportunities',
  #   'sales/break_even',
  #   'sales/forecast',
  #   'sales/performance'
  # ]

end
