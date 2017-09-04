json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :custom_schema, :free_trial_enabled, :free_trial_duration, :free_trial_unit

json.product_pricings do
  json.array! product.product_pricings.each do |pricing|
    json.id pricing.id
    json.name pricing.name
    json.description pricing.description
    json.free pricing.free
    json.free_trial_enabled pricing.free_trial_enabled
    json.free_trial_duration pricing.free_trial_duration
    json.free_trial_unit pricing.free_trial_unit
    json.position pricing.position
    json.per_duration pricing.per_duration
    json.per_unit pricing.per_unit
    json.prices pricing.prices
    json.external_id pricing.external_id
  end
end
