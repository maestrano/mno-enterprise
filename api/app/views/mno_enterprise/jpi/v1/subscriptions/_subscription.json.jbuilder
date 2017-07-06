json.extract! subscription, :id, :status, :subscription_type, :start_date, :end_date, :max_licenses,
              :available_licenses, :external_id, :custom_data, :product_instance_id, :product_contract_id,
              :organization_id, :user_id, :product_pricing_id

if product_pricing = subscription.product_pricing
  json.product_pricing do
    json.extract! product_pricing, :id, :name, :description, :free, :free_trial_enabled, :free_trial_duration,
                  :free_trial_unit, :position, :per_duration, :per_unit, :prices, :external_id, :product_id
  end
  if product = product_pricing['product']
    json.product do
      json.extract! product, :id, :name, :product_type
    end
  end
end

