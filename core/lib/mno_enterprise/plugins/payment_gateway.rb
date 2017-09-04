module MnoEnterprise
  module Plugins
    class PaymentGateway < Base
      # == Constants ============================================================
      CONFIG_JSON_SCHEMA = {
        '$schema': "http://json-schema.org/draft-04/schema#",
        title: "Payment Gateway Configuration",
        type: "array",
        items: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Friendly name for your gateway."
            },
            provider: {
              type: "object",
              properties: {
                adapter: {
                  type: "string",
                  description: "Payment Gateway provider",
                  enum: ["braintree"],
                  default: "braintree"
                },
                config: {
                  type: "object",
                  properties: {
                    merchant_id: {
                      type: "string",
                      description: "Enter the merchant ID provided by Braintree"
                    },
                    public_key: {
                      type: "string",
                      'x-schema-form': {
                        type: 'textarea',
                        description: "Enter the public key provided by Braintree"
                      }
                    },
                    private_key: {
                      type: "string",
                      'x-schema-form': {
                        type: 'textarea',
                        description: "Enter the private key provided by Braintree"
                      }
                    }
                  },
                  required: ["merchant_id", "public_key", "private_key"]
                }
              },
            },
            accounts: {
              type: "array",
              title: "Merchant Account / Currency mapping",
              default: [],
              items: {
                type: "object",
                properties: {
                  currency: {
                    type: "string",
                    # TODO: enum
                    enum: ["AED", "AUD", "USD"]
                  },
                  acct: {
                    type: "string",
                    title: "account",
                    description: "Name of merchant account",
                  },
                  fallback_order: {
                    type: "integer",
                    description: "Fallback order"
                  },
                  american_express: {
                    type: "boolean",
                    description: "Does this account accept Amex",
                    default: false
                  },
                  jcb: {
                    type: "boolean",
                    description: "Does this account accept JCB",
                    default: false
                  }
                },
                required: ["currency", "acct"]
              }
            }
          }
        }
      }.with_indifferent_access.freeze

      # == Constants ============================================================

      # == Attributes ===========================================================
      attr_accessor :config

      # == Validations ==========================================================

      # == Scopes ===============================================================

      # == Callbacks ============================================================

      # == Class Methods ========================================================

      # == Instance Methods =====================================================
      def save
        tenant.keystore ||= {}
        tenant.keystore['payment_gateways'] = transform
        tenant.attribute_will_change!(:keystore)
      end

      # Display current config (opposite of #transform)
      def show_config
        gw_config = Hash(tenant.keystore).fetch('payment_gateways', {})

        config = Array(gw_config['providers']).map do |name, config|
          accounts = Hash(gw_config['accounts'] && gw_config['accounts'][name])
          {
            "name": name,
            "provider": config,
            "accounts": accounts.map do |curr, acc|
              acc.merge(currency: curr)
            end
          }
        end

        { "payment_gateways": config }.with_indifferent_access
      end

      # Transform the configuration hash coming from the schema to the format
      # expected in the backend
      def transform
        providers = {}
        accounts = {}

        config.each do |gw|
          providers[gw[:name]] = gw[:provider]
          acct_list = gw[:accounts].map do |acc|
            [acc[:currency], acc.except(:currency)]
          end
          accounts[gw[:name]] = Hash[acct_list]
        end

        {
          providers: providers,
          accounts: accounts
        }.with_indifferent_access
      end
    end
  end
end
