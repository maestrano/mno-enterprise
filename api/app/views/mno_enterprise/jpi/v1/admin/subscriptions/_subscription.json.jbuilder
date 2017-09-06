json.id subscription.id
json.status subscription.status
json.subscription_type subscription.subscription_type
json.start_date subscription.start_date
json.end_date subscription.end_date
json.max_licenses subscription.max_licenses
json.available_licenses subscription.available_licenses
json.external_id subscription.external_id
json.custom_data subscription.custom_data

json.product_pricing_id subscription.product_pricing&.id
if subscription.product_pricing
  json.product_pricing do
    json.id subscription.product_pricing.id
    json.name subscription.product_pricing.name
    json.description subscription.product_pricing.description
    json.free subscription.product_pricing.free
    json.free_trial_enabled subscription.product_pricing.free_trial_enabled
    json.free_trial_duration subscription.product_pricing.free_trial_duration
    json.free_trial_unit subscription.product_pricing.free_trial_unit
    json.position subscription.product_pricing.position
    json.per_duration subscription.product_pricing.per_duration
    json.per_unit subscription.product_pricing.per_unit
    json.prices subscription.product_pricing.prices
    json.external_id subscription.product_pricing.external_id
  end

  json.product_id subscription.product_pricing.product&.id
  if subscription.product_pricing.product
    json.product do
      json.id subscription.product_pricing.product.id
      json.name subscription.product_pricing.product.name
      json.product_type subscription.product_pricing.product.product_type
    end
  end
end

json.product_instance_id subscription.product_instance&.id
json.contract_id subscription.product_contract&.id
json.organization_id subscription.organization&.id
if subscription.organization
  json.organization do
    json.id subscription.organization.id
    json.name subscription.organization.name
  end
end
json.user_id subscription.user&.id
json.billed_locally subscription.billed_locally
json.externally_provisioned subscription.externally_provisioned
json.local_product subscription.local_product
