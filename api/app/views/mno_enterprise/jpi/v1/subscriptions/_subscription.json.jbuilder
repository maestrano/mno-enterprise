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
json.available_actions subscription.available_actions

json.product_pricing_id subscription.product_pricing&.id
if subscription.product_pricing
  json.product_pricing do
    json.partial! 'mno_enterprise/jpi/v1/product_pricing/product_pricing', product_pricing: subscription.product_pricing
  end
end

json.product_id subscription.product&.id
if subscription.product
  json.product do
    json.id subscription.product.id
    json.name subscription.product.name
    json.product_type subscription.product.product_type
    json.nid subscription.product.nid
    json.single_billing_enabled subscription.product.single_billing_enabled
    json.billed_locally subscription.product.billed_locally
    json.externally_provisioned subscription.externally_provisioned
  end
end

json.product_instance_id subscription.product_instance&.id
json.contract_id subscription.product_contract&.id
json.organization_id subscription.organization&.id
json.user_id subscription.user&.id
