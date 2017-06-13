MnoEnterprise.configure do |config|
  #===============================================
  # General Configuration
  #===============================================
  # Name of your company/application
  config.app_name = '<%= @company_name || "My Company" %>'

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
  # Adapter used to send emails
  # Default to :smtp
  # config.mail_adapter = :mandrill
  # config.mail_adapter = :sparkpost
  # config.mail_adapter = :smtp

  # Support email address
  config.support_email = '<%= @support_email || "support@example.com" %>'

  # Default sender for system generated emails
  config.default_sender_name = '<%= @company_name || "My Company" %>'
  config.default_sender_email = '<%= @system_email || "no-reply@example.com" %>'

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
  config.i18n_enabled = false

  #===============================================
  # Third Party Plugins
  #===============================================
  # Google Tag Manager
  config.google_tag_container = ENV['google_tag_container']

  # Intercom (both API Keys and Personal token are supported)
  config.intercom_token = ENV['INTERCOM_TOKEN']
  config.intercom_app_id = ENV['INTERCOM_APP_ID']
  config.intercom_api_key = ENV['INTERCOM_API_KEY']
  config.intercom_api_secret = ENV['INTERCOM_API_SECRET']

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
