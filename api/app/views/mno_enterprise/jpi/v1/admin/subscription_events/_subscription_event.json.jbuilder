json.id subscription_event.id
json.event_type subscription_event.event_type
json.status subscription_event.status
json.message subscription_event.message
json.provisioning_data subscription_event.provisioning_data
json.created_at subscription_event.created_at
json.updated_at subscription_event.updated_at

if subscription_event.subscription
  subscription = subscription_event.subscription

  json.subscription do
    json.product_id subscription.product_id
    json.start_date subscription.start_date
    json.organization_name subscription.organization&.name
    json.product_name subscription.product&.name
    json.product_pricing_name subscription.product_pricing&.name
  end
end
