json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :single_billing_enabled, :billed_locally, :created_at, :updated_at

if product.custom_schema
  schema = JSON.parse(product.custom_schema)
  # When a custom_schema has angular-schema-form options, the custom_schema will be namespaced under #json_schema.

  custom_schema = schema['json_schema'] ? schema['json_schema'].to_json : schema.to_json
  asf_options = schema['asf_options'] ? schema['asf_options'].to_json : nil

  json.custom_schema custom_schema
  json.asf_options asf_options
end

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

json.categories product.categories&.map(&:name) if product.respond_to?(:categories)
