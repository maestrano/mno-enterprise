json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :local, :single_billing_enabled, :billed_locally

json.values_attributes do
  if product.respond_to?(:values)
    json.array! product.values.each do |value|
      json.extract! value, :data
      json.name value.field.name
    end
  end
end

json.assets_attributes do
  if product.respond_to?(:assets)
    json.array! product.assets.each do |asset|
      json.extract! asset, :id, :url, :field_name
    end
  end
end

json.pricing_plans do
  if product.respond_to?(:pricing_plans)
    json.array! product.pricing_plans.each do |pricing|
      json.extract! pricing, :id, :name, :description, :position, :free, :license_based, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id, :quote_based
    end
  end
end

json.js_editor_enabled product.nid.in? Settings.product_nids.to_a
