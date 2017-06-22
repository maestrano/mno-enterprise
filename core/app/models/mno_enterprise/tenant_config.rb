# frozen_string_literal: true
module MnoEnterprise
  # Frontend configuration management
  class TenantConfig
    # == Constants ============================================================
    # JSON schema for the configuration
    # This is used to provide default values and to generate the form in the frontend
    # This *MUST* be updated any time a new feature flag is added
    CONFIG_JSON_SCHEMA = {
      '$schema': "http://json-schema.org/draft-04/schema#",
      type: "object",
      title: "Settings",
      properties: {
        audit_log: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Display Audit Log in Organization Panel",
              default: false
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
        devise: {
          type: "object",
          properties: {
            registration: {
              type: "object",
              properties: {
                enabled:  {
                  type: "boolean",
                  description: "Enable user registration",
                  default: true
                }
              }
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
            comparison: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: false,
                  description: "Enable comparison of apps"
                }
              }
            }
          }
        },
        onboarding_wizard: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              default: false,
              description: "Enable the onboarding wizard"
            }
          }
        },
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
              default: true
            }
          }
        },
        # TODO: nest under marketplace
        pricing: {
          type: "object",
          properties: {
            enabled: {
              type: "boolean",
              description: "Display App Pricing on Marketplace",
              default: true
            }
          }
        },
        # TODO: nest under marketplace
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
        admin_panel: {
          description: "Admin Panel Settings",
          type: "object",
          properties: {
            apps_management: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true
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
            customer_management: {
              type: "object",
              properties: {
                organization: {
                  type: "object",
                  properties: {
                    enabled: {
                      type: "boolean",
                      default: true
                    }
                  }
                },
                user: {
                  type: "object",
                  properties: {
                    enabled: {
                      type: "boolean",
                      default: true
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
                  description: "disable the finance page, the financial kpis and the invoices in the admin panel"
                }
              }
            },
            impersonation: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true
                }
              }
            },
            staff: {
              type: "object",
              properties: {
                enabled: {
                  type: "boolean",
                  default: true
                }
              }
            }
          }
        }
      }
    }.with_indifferent_access.freeze

    # == Extensions ===========================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================
    # @return [Hash] Config hash
    def self.to_hash
      build_object(CONFIG_JSON_SCHEMA)
    end

    # Render a YAML representation of the config
    # Mostly used for debugging purppose
    # @return [String] YAML representation of the config
    def self.to_yaml
      to_hash.to_yaml
    end

    # Load the Tenant#frontend_config from MnoHub and add it to the settings
    #
    #  TODO: include retry/caching/...
    def self.load_config!
      return unless (frontend_config = fetch_tenant_config)

      # Merge the settings and reload
      Settings.add_source!(frontend_config)
      Settings.reload!

      # TODO: update JSON_SCHEMA with readonly fields

      # # Save settings in YAML format for easy debugging
      # Rails.logger.debug "Settings loaded -> Saving..."
      # File.open(Rails.root.join('tmp', 'cache', 'settings.yml'), 'w') do |f|
      #   f.write(Settings.to_hash.deep_stringify_keys.to_yaml)
      # end
    end


    # Fetch the Tenant#frontend_config from MnoHub
    #
    # @return [Hash] Tenant configuration
    def self.fetch_tenant_config
      MnoEnterprise::Tenant.show.frontend_config
    rescue JsonApiClient::Errors::ConnectionError
      Rails.logger.warn "Couldn't get configuration from MnoHub"
      puts "Couldn't get configuration from MnoHub"
    end

    # Convert JSON Schema to hash with default value
    #
    # @param [Hash] schema JSON schema to parse
    def self.build_object(schema)
      case schema['type']
      when 'string', 'integer', 'boolean'
        schema['default']
      when 'object'
        h = {}
        schema['properties'].each do |k, inner_schema|
          h[k] = build_object(inner_schema)
        end
        h.compact
      end
    end
  end
end
