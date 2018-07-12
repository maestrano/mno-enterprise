json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :single_billing_enabled, :billed_locally, :created_at, :updated_at

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
    json.partial! 'mno_enterprise/jpi/v1/admin/product_pricing/product_pricing', product_pricing: pricing
  end if product.respond_to?(:product_pricings)
end

json.categories product.categories&.map(&:name) if product.respond_to?(:categories)
json.js_editor_enabled product.nid.in? Settings.product_nids.to_a
