json.extract! organization, :id, :name, :soa_enabled, :payment_restriction, :account_frozen, :billing_currency
json.active organization.active?
