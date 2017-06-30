json.extract! product, :id, :nid, :name, :active, :product_type, :logo, :external_id, :externally_provisioned, :custom_schema

json.product_pricings do
  json.array! product.product_pricings.each { |pricing| json.extract! pricing, :id, :name, :description, :free, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :position, :per_duration, :per_unit, :prices, :external_id }
end
