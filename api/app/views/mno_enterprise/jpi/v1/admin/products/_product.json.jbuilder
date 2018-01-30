json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :custom_schema, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :created_at, :updated_at

json.values_attributes do
  json.array! product.values.each do |value|
    json.extract! value, :data
    json.name value.field.name
  end if product.respond_to?(:values)
end

json.assets_attributes do
  json.array! product.assets.each do |asset|
    json.extract! asset, :id, :url, :field_name
  end if product.respond_to?(:assets)
end

json.product_pricings do
  json.array! product.product_pricings.each do |pricing|
    json.extract! pricing, :id, :name, :description, :position, :free, :license_based, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id
  end if product.respond_to?(:product_pricings)
end
