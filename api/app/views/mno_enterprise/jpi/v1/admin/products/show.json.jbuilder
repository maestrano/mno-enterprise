json.product do
  json.partial! 'product', product: @product

  json.product_pricings @product.product_pricings do |product_pricing|
    json.extract! product_pricing, :id, :name, :description, :position, :free, :license_based, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id
  end
end
