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
      description: "System Settings",
      properties: {
        app_name: {
          type: "string",
          description: "Application Name",
          default: "My Company"
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
              type: ["string", "null"],
              description: "Intercom <a href='https://docs.intercom.com/faqs-and-troubleshooting/getting-set-up/where-can-i-find-my-app-id'>app ID</a>",
              default: ENV['INTERCOM_APP_ID'],
              'x-schema-form': {}
            },
            api_secret: {
              type: ["string", "null"],
              description: "Secure mode secret",
              default: ENV['INTERCOM_API_SECRET']
            },
            token: {
              type: ["string", "null"],
              description: "OAuth or Personal Access token",
              default: ENV['INTERCOM_TOKEN']
            }
          }
        },
        smtp: {
          description: "SMTP Settings",
          type: "object",
          properties: {
            authentication: {
              type: "string",
              description: "Mail server authentication type",
              default: "plain",
              enum: ["plain", "login", "cram_md5"]
            },
            address: {
              type: "string",
              description: "Mail server address",
              default: "localhost"
            },
            port: {
              type: "integer",
              description: "Mail server port",
              default: 25
            },
            domain: {
              type: "string",
              description: "HELO domain"
            },
            user_name: {
              type: "string",
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
          description: "System email settings",
          properties: {
            support_email: {
              type: "string",
              description: "Support email address. Displayed in the frontend",
              default: "support@example.com"
            },
            default_sender: {
              type: "object",
              description: "Default sender for system generated emails",
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
        },
        i18n: {
          type: "object",
          description: "Internationalization settings",
          properties: {
            preferred_locale: {
              title: "Platform Language",
              type: "string",
              description: "Default locale used when no locale has been specified by the user",
              default: 'en-AU',
              enum: ['en-AU'],
              'x-schema-form': {
                titleMap: {'en-AU': 'English (Australia)'}
              }
            },
            enabled: {
              type: "boolean",
              description: "Enable internationalization",
              default: false
            },
            available_locales: {
              title: "Available Locales",
              type: "array",
              description: "List of locales available to the end user",
              items: {
                type: "string",
                # TODO: double check # Proc?
                enum: I18n.available_locales,
                default: ['en-AU']
              },
              'x-schema-form': {
                titleMap: {'en-AU': 'English (Australia)'}
              }
            }
          }
        }
      }
    },
    dashboard: {
      type: "object",
      description: "Dashboard settings",
      properties: {
        audit_log: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Display Audit Log in Organization Panel",
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
        dock: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable the App Dock",
              default: true
            }
          }
        },
        marketplace: {
          type: "object",
          description: "Marketplace configuration",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable the marketplace"
            },
            provisioning: {
              type: "boolean",
              default: false,
              description: "Enable the provisioning workflow"
            },
            local_products: {
              type: "boolean",
              default: false,
              description: "Enable the local products"
            },
            comparison: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Enable comparison of apps"
                }
              }
            },
            pricing: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  description: "Display App Pricing on Marketplace",
                  default: true
                },
                # currency: {
                #   type: "string",
                #   description: "Currency to display price in",
                #   default: "AUD"
                # }
              }
            },
            questions: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Enable app questions on the marketplace"
                }
              }
            },
            reviews: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Enable app reviews on the marketplace"
                }
              }
            },
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
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Allow user to create and manage Organizations",
            },
            billing: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Display the billing tab"
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
              description: "Enable payment section in the company settings"
            }
          }
        },
        public_pages: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: false,
              description: "Enable a public landing page (instead of being directed to the sign in page)"
            },
            display_pricing: {
              type: "boolean",
              default: false,
              description: "Display pricings in public product pages"
            },
            applications: {
              title: "Applications",
              type: "array",
              description: "List of applications displayed on the public landing page as app cards",
              items: {
                type: "string",
                enum: [],
                default: []
              },
              'x-schema-form': {
                titleMap: {}
              }
            },
            highlighted_applications: {
              title: "Highlighted Applications",
              type: "array",
              description: "List of applications that will be hightlighted in the landing page carousel",
              items: {
                type: "string",
                enum: [],
                default: [],

              },
              'x-schema-form': {
                titleMap: {}
              }
            }
          }
        },
        registration: {
          type: "object",
          properties: {
            enabled:  {
              type: "boolean",
              description: "Enable user registration",
              default: true
            }
          }
        },
        user_management: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Allow user to edit their information and password"
            }
          }
        },

      }
    },
    admin_panel: {
      description: "Settings controlling the behavior of the Admin Panel",
      type: "object",
      properties: {
        apps_management: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable adding/removing apps (connection of existing apps is still possible) from the admin panel"
            }
          }
        },
        audit_log: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable the audit log",
              default: true
            }
          }
        },
        customer_batch_import: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable the Customer Batch Import via CSV",
              default: false
            }
          }
        },
        dashboard_templates: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Enable the dashboard designer",
              default: false
            }
          }
        },
        customer_management: {
          type: "object",
          properties: {
            organization: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Control the ability to create or invite customers from the admin panel"
                }
              }
            },
            user: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true,
                  description: "Control the ability to add users to organizations from the admin panel"
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
              description: "Enable the finance page, the financial kpis and the invoices"
            }
          }
        },
        impersonation: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Control the ability to impersonate users from the admin panel"
            },
            consent_required: {
              type: "boolean",
              default: false,
              description: "Is consent required to be able to impersonate"
            }
          }
        },
        staff: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable staff management"
            }
          }
        },
        settings: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: true,
              description: "Enable frontend configuration from the Admin Panel"
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
              description: "enable sub tenant management from the Admin Panel"
            }
          }
        },
        available_billing_currencies: {
          title: "Available Billing Currencies",
          type: "array",
          description: "List of billing currencies available",
          items: {
            type: "string",
            enum: %w(AED AUD CAD EUR GBP HKD JPY NZD SGD USD),
            default: %w(AED AUD CAD EUR GBP HKD JPY NZD SGD USD)
          }
        }
      }
    }
  }
}.with_indifferent_access.freeze
