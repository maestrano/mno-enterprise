json.id subscription_event.id
json.event_type subscription_event.event_type
json.status subscription_event.status
json.message subscription_event.message
json.obsolete subscription_event.obsolete
json.provisioning_data subscription_event.provisioning_data
json.created_at subscription_event.created_at
json.updated_at subscription_event.updated_at
json.user_name subscription_event.user_name
json.product_pricing do
  json.name subscription_event.product_pricing&.name
end

if subscription_event.subscription
  subscription = subscription_event.subscription

  json.subscription do
    json.id subscription.id
    json.product_id subscription.product_id
    json.start_date subscription.start_date
    json.organization_name subscription.organization&.name
    json.organization_id subscription.organization&.id
    json.product_name subscription.product&.name
  end
end
