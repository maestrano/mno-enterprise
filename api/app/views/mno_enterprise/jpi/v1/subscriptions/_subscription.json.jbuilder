json.id subscription.id
json.status subscription.status
json.subscription_type subscription.subscription_type
json.start_date subscription.start_date
json.end_date subscription.end_date
json.currency subscription.currency
json.max_licenses subscription.max_licenses
json.available_licenses subscription.available_licenses
json.external_id subscription.external_id
json.custom_data subscription.custom_data
json.provisioning_data subscription.provisioning_data
json.available_edit_actions subscription.available_edit_actions

json.product_pricing_id subscription.product_pricing&.id
if subscription.product_pricing
  json.product_pricing do
    json.id subscription.product_pricing.id
    json.name subscription.product_pricing.name
    json.description subscription.product_pricing.description
    json.free subscription.product_pricing.free
    json.license_based subscription.product_pricing.license_based
    json.pricing_type subscription.product_pricing.pricing_type
    json.free_trial_enabled subscription.product_pricing.free_trial_enabled
    json.free_trial_duration subscription.product_pricing.free_trial_duration
    json.free_trial_unit subscription.product_pricing.free_trial_unit
    json.position subscription.product_pricing.position
    json.per_duration subscription.product_pricing.per_duration
    json.per_unit subscription.product_pricing.per_unit
    json.prices subscription.product_pricing.prices
    json.external_id subscription.product_pricing.external_id
  end

end

json.product_id subscription.product&.id
if subscription.product
  json.product do
    json.id subscription.product.id
    json.name subscription.product.name
    json.product_type subscription.product.product_type
  end
end

json.product_instance_id subscription.product_instance&.id
json.contract_id subscription.product_contract&.id
json.organization_id subscription.organization&.id
json.user_id subscription.user&.id
