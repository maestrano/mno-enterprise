# Third Party plugins configuration schema
MnoEnterprise::PLUGINS_CONFIG_JSON_SCHEMA = {
  '$schema': "http://json-schema.org/draft-04/schema#",
  title: "Plugins Configuration",
  type: "object",
  properties: {
    payment_gateways: MnoEnterprise::Plugins::PaymentGateway::CONFIG_JSON_SCHEMA
  }
}.with_indifferent_access.freeze

# JSON schema for the configuration
# This is used to provide default values and to generate the form in the frontend
# This *MUST* be updated any time a new feature flag is added
#
# Do not use this constant directly, instead use MnoEnterprise::TenantConfig.json_schema
MnoEnterprise::CONFIG_JSON_SCHEMA = {
  '$schema': "http://json-schema.org/draft-04/schema#",
  type: "object",
  title: "Settings",
  properties: {
    system: {
      type: "object",
      title: "General settings",
      description: "This section enables you to set general settings for you webstore",
      properties: {
        app_name: {
          type: "string",
          title: "Webstore name",
          description: "Name displayed in the browser title bar and in the public pages",
          default: "My Webstore"
        },
        organization_requirements: {
          type: "array",
          title: "Webstore organization requirements",
          description: "Information required for new organizations",
          default: [],
          items: {
            type: "string",
            enum: MnoEnterprise::Organization::REQUIRABLE_FIELDS
          },
          'x-schema-form': {
            titleMap: Hash[MnoEnterprise::Organization::REQUIRABLE_FIELDS.map{|f| [f, f.titleize]}]
          }
        },
        i18n: {
          type: "object",
          title: "Internationalization",
          description: "Internationalization settings",
          properties: {
            preferred_locale: {
              title: "Webstore Language",
              type: "string",
              description: "Default language of the webstore",
              default: 'en-AU',
              enum: ['en-AU'],
              'x-schema-form': {
                titleMap: {'en-AU': 'English (Australia)'}
              }
            },
            enabled: {
              type: "boolean",
              description: "Allow user to change the webstore language",
              default: false
            },
            available_locales: {
              title: "Available languages",
              type: "array",
              description: "List of languages available to the end user",
              default: ['en-AU'],
              items: {
                type: "string",
                # TODO: double check # Proc?
                enum: I18n.available_locales,
              },
              'x-schema-form': {
                titleMap: {'en-AU': 'English (Australia)'}
              }
            }
          }
        },
        advanced_config: {
          type: "object",
          title: "Advanced settings",
          description: "The following settings are optional and should be managed by someone with technical abilities",
          properties: {}
        },
        intercom: {
          # https://maestrano.atlassian.net/wiki/x/cRvrBQ
          title: "Intercom Integration",
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable Intercom integration",
              default: false
            },
            app_id: {
              type: "string",
              title: "Intercom app ID",
              description: "To find your Intercom app ID, <a href='https://docs.intercom.com/faqs-and-troubleshooting/getting-set-up/where-can-i-find-my-app-id'>click here</a>",
              default: ENV['INTERCOM_APP_ID'].presence || '',
              'x-schema-form': {}
            },
            api_secret: {
              type: "string",
              title: "Intercom identity verification secret",
              description: "<a href='https://docs.intercom.com/configure-intercom-for-your-product-or-site/staying-secure/enable-identity-verification-on-your-web-product'>Learn more about web identity verification</a>",
              default: ENV['INTERCOM_API_SECRET'].presence || ''
            },
            token: {
              type: "string",
              title: "Intercom token",
              description: "OAuth or Personal Access token",
              default: ENV['INTERCOM_TOKEN'].presence || ''
            }
          }
        },
        smtp: {
          title: "Email server settings",
          description: "SMTP settings",
          type: "object",
          properties: {
            authentication: {
              type: "string",
              title: "Authentication type",
              description: "Mail server authentication type",
              default: "plain",
              enum: ["plain", "login", "cram_md5"]
            },
            address: {
              type: "string",
              title: "Server address",
              description: "Mail server address",
              default: "localhost"
            },
            port: {
              type: "integer",
              title: "Server port",
              description: "Mail server port",
              default: 25
            },
            domain: {
              type: "string",
              title: "Server address",
              description: "HELO domain"
            },
            user_name: {
              type: "string",
              title: "Username",
              description: "Mail username"
            },
            password: {
              type: "string",
              description: "Mail password"
            }
          }
        },
        email: {
          type: "object",
          title: "Email address",
          description: "System email settings",
          properties: {
            support_email: {
              type: "string",
              title: "Support email address",
              description: "Support email address. displayed in the webstore",
              default: "support@example.com"
            },
            default_sender: {
              type: "object",
              title: "Default sender email address",
              description: "Default sender for emails sent from your webstore",
              properties: {
                email: {
                  type: "string",
                  # description: "Default sender email for system generated emails",
                  default: "no-reply@example.com"
                },
                name: {
                  type: "string",
                  # description: "Default sender name for system generated emails",
                  default: "no-reply@example.com"
                }
              }
            }
          }
        }
      }
    },
    dashboard: {
      type: "object",
      title: "Customer features",
      description: "This section lets you decide which functionalities are visible to your customer",
      properties: {
        marketplace: {
          type: "object",
          description: "Marketplace configuration",
          properties: {
            enabled: {
              type: "boolean",
              title: "Enable the marketplace",
              default: true,
              description: "Enables the marketplace, ie. the ability for the customer to add apps and products"
            },
            provisioning: {
              type: "boolean",
              default: true,
              title: "Product ordering",
              description: "Enable the ordering of products"
            },
            product_markup: {
              type: "boolean",
              default: true,
              title: "Product Markup",
              description: "Enable the markup feature for products"
            },
            local_products: {
              type: "boolean",
              default: false,
              title: "Your product catalog",
              description: "Display your specific product catalog"
            },
            comparison: {
              type: "object",
              title: "Product comparison",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Enable comparison of products in the marketplace"
                }
              }
            },
            pricing: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  description: "Display Product pricing information on the Marketplace",
                  default: true
                },
                currency: {
                  type: "string",
                  description: "Currency to display price in",
                  default: "AUD"
                },
                currency_selection: {
                  type: "boolean",
                  title: "Currency Selection",
                  default: true,
                  description: "Allow user to choose a different currency when placing an order"
                }
              }
            },
            questions: {
              type: "object",
              title: "Product questions",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Display questions on products on the marketplace"
                }
              }
            },
            reviews: {
              type: "object",
              title: "Product reviews",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Display and allow products reviews on the marketplace"
                }
              }
            },
            connection_speedbump: {
              type: "object",
              title: "Connection Speedbump Page",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Display a redirection warning page to users when they connect a product for data sharing purpose"
                }
              }
            }
          }
        },
        # commented until products are properly handled
        # onboarding_wizard: {
        #   type: "object",
        #   properties: {
        #     enabled: {
        #       type: "boolean",
        #       default: false,
        #       description: "Enable the onboarding wizard"
        #     }
        #   }
        # },
        organization_management: {
          type: "object",
          title: "Organization management",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Allow your customer to create companies and enable the 'Company' menu",
            },
            billing: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Display information about billing (invoices...)"
                },
                billing_currency_selection: {
                  type: "boolean",
                  title: "Billing Currency Selection",
                  description: "Allow your customer to change their billing currency",
                  default: true
                },
                invoice_contact_details: {
                  type: "string",
                  maxLength: 100,
                  title: "Invoice Contact Details",
                  description: "Let your customer know who to contact for invoice support.",
                  default: ""
                },
                invoice_payment_information: {
                  type: "string",
                  title: "Invoice Payment Information",
                  description: "Payment information (e.g. Payment via wire transfer...)",
                  default: ""
                }
              }
            }
          }
        },
        # TODO: break - changed  disabled to enabled
        payment: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Allow your customer to add a credit card"
            }
          }
        },
        public_pages: {
          type: "object",
          title: "Public pages",
          properties: {
            enabled: {
              type: "boolean",
              default: false,
              title: "Enable public pages",
              description: "Enable a public landing page displaying general information on your webstore, before the sign in page"
            },
            display_pricing: {
              type: "boolean",
              default: false,
              title: "Display pricing",
              description: "Display product pricings in public pages"
            },
            applications: {
              title: "Products",
              type: "array",
              description: "List of products featured on the public landing page",
              default: [],
              items: {
                type: "string",
                enum: []
              },
              'x-schema-form': {
                titleMap: {}
              }
            },
            highlighted_applications: {
              title: "Highlighted Products",
              type: "array",
              description: "List of products that will be hightlighted in the landing page carousel",
              default: [],
              items: {
                type: "string",
                enum: []
              },
              'x-schema-form': {
                titleMap: {}
              }
            },
            local_products: {
              title: "My products",
              type: "array",
              description: "List of my products featured on the public landing page",
              default: [],
              items: {
                type: "string",
                enum: []
              },
              'x-schema-form': {
                titleMap: {}
              }
            },
            highlighted_local_products: {
              title: "My Highlighted Products",
              type: "array",
              description: "List of my products that will be hightlighted in the landing page carousel",
              default: [],
              items: {
                type: "string",
                enum: []
              },
              'x-schema-form': {
                titleMap: {}
              }
            }
          }
        },
        registration: {
          type: "object",
          title: "Customer registration",
          properties: {
            enabled:  {
              type: "boolean",
              description: "Enable your customer to create an account themselves",
              default: true
            }
          }
        },
        user_management: {
          type: "object",
          title: "Customer user information management",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Allow customer to edit their information and password"
            }
          }
        },
        dock: {
          type: "object",
          title: "Application dock",
          properties: {
            enabled: {
              type: "boolean",
              description: "Displays the list of apps and products at the top of the customer homepage",
              default: true
            }
          }
        },
        impac: {
          type: "object",
          title: "Impac Dashboard",
          properties: {
            enabled: {
              type: "boolean",
              description: "Displays the Impac! analytics dashboard",
              default: true
            }
          }
        },
        apps_management: {
          type: "object",
          title: "App Management",
          properties: {
            enabled: {
              type: "boolean",
              description: "Allow customer to manage apps",
              default: false
            }
          }
        },
        data_sharing: {
          type: "object",
          title: "Data Sharing",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable data sharing for apps",
              default: false
            }
          }
        },
        audit_log: {
          type: "object",
          title: "Audit log",
          properties: {
            enabled: {
              type: "boolean",
              description: "Display Audit Log (list of actions took by the customer) in the Organization Panel",
              default: false,
              readonly: true
            }
          }
        },
        developer: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Display the Developer section on \"My Account\"",
              default: false
            }
          }
        },
      }
    },
    admin_panel: {
      title: "Admin feature",
      description: "This section lets you customize which functionalities you want to see in the Control Panel",
      type: "object",
      properties: {
        customer_batch_import: {
          type: "object",
          title: "Mass import of customers ",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enables you to import existing customers via a file upload",
              default: false
            }
          }
        },
        apps_management: {
          type: "object",
          title: "Apps management",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Allow you to manage your customer's app (add apps / remove apps)"
            }
          }
        },
        customer_management: {
          type: "object",
          title: "Customer management",
          description: "Control the ability to manage companies and users",
          properties: {
            organization: {
              type: "object",
              title: "Company",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Control the ability to create companies from the Control panel"
                }
              }
            },
            user: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Control the ability to add users to companies from the Control Panel"
                }
              }
            }
          }
        },
        finance: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable the finance page, the financial kpis and the display of invoices"
            }
          }
        },
        impersonation: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Control the ability to impersonate users (login to the webstore with their identity) from the Control Panel"
            },
            consent_required: {
              type: "boolean",
              default: false,
              title: "Consent required",
              description: "Is consent from the user required to be able to impersonate him"
            }
          }
        },
        staff: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable staff management, ie. the possibility to add admin users and staff users with limited rights"
            }
          }
        },
        settings: {
          type: "object",
          # Don't let user lock itself out of settings
          'x-schema-form': {
            type: 'hidden',
            notitle: true
          },
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable settings in Control Panel"
            }
          }
        },
        support: {
          type: "object",
          title: "Support",
          properties: {
            enabled: {
              type: "boolean",
              default: false,
              description: "Enable support users who can selectively view organization information"
            }
          }
        },
        sub_tenant: {
          type: "object",
          # Disable sub_tenant activation for now
          'x-schema-form': {
            type: 'hidden',
            notitle: true
          },
          properties: {
            enabled: {
              type: "boolean",
              default: false,
              description: "enable sub tenant management from the Control Panel"
            }
          }
        },
        billing_section: {
          type: "object",
          title: "Billing",
          properties: {}
        },
        available_billing_currencies: {
          title: "Available Billing Currencies",
          type: "array",
          description: "List of billing currencies available",
          default: %w(AED AUD CAD EUR GBP HKD JPY NZD SGD USD),
          items: {
            type: "string",
            enum: %w(AED AUD CAD EUR GBP HKD JPY NZD SGD USD)
          }
        },
        dashboard_templates: {
          type: "object",
          title: "Dashboard templates",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable the dashboard designer",
              default: false
            }
          }
        },
        view_user_dashboards: {
          type: "object",
          title: "View user Dashboards",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable admin view of user's dashboards",
              default: false
            }
          }
        },
        audit_log: {
          type: "object",
          title: "Audit log",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable the audit log",
              default: true
            }
          }
        },
        tenant_reporting: {
          title: 'Reporting',
          description: 'Tenant Reporting',
          type: 'object',
          properties: {
            currency: {
              type: 'string',
              title: 'Reporting Currency',
              description: 'Currency for Tenant reporting purposes',
              default: 'AUD',
              enum: %w(AED AUD CAD EUR GBP HKD JPY NZD SGD USD)
            }
          }
        },
      }
    },
    authentication: {
      title: 'Authentication feature',
      description: 'Authentication feature',
      type: 'object',
      properties: {
        session_limitable: {
          title: 'Session limitable',
          description: 'This option limits the number of active sessions per user to one: if the user attempts to create a new session, the old ones become invalid',
          type: 'object',
          properties: {
            enabled: {
              type: 'boolean',
              description: 'Enabled?',
              default: false
            }
          }
        },
        two_factor: {
          title: 'Two factor',
          description: 'Two factor',
          type: 'object',
          properties: {
            admin_enabled: {
              type: 'boolean',
              description: 'Enable for admin',
              default: false
            },
            app_id: {
              type: 'string',
              description: 'App id to display on the authenticator',
              default: ''
            },
            app_name: {
              type: 'string',
              description: 'App name to display on the authenticator',
              default: ''
            },
            users_enabled: {
              type: 'boolean',
              description: 'Enable for users',
              default: false
            }
          }
        }
      }
    }
  }
}.with_indifferent_access.freeze
