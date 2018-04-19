json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :custom_schema, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :local, :values_attributes

json.assets_attributes do
  json.array! product.assets.each do |asset|
    json.extract! asset, :id, :url, :field_name
  end if product.respond_to?(:assets)
end

json.pricing_plans do
  json.array! product.pricing_plans.each do |pricing|
    json.extract! pricing, :id, :name, :description, :position, :free, :license_based, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id
  end if product.respond_to?(:pricing_plans)
end
