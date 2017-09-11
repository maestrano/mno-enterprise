json.extract! product, :id, :nid, :name, :active, :logo, :external_id, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :created_at, :updated_at

json.values_attributes do
  json.array! product.values.each do |value|
    json.extract! value, :data
    json.name value.field.name
  end
end

json.assets_attributes do
  json.array! product.assets.each do |asset|
    json.extract! asset, :id, :url, :field_name
  end
end

json.product_pricings do
  json.array! product.product_pricings.each do |pricing|
    json.extract! pricing, :id, :name, :description, :position, :free, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id
  end
end
