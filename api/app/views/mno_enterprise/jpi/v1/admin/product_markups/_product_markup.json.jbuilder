json.extract! product_markup, :id, :percentage, :created_at

json.product do
  json.id product_markup.product.id
  json.name product_markup.product.name
  json.nid product_markup.product.nid

  json.product_pricings do
    json.array! product_markup.product.product_pricings.each do |pricing|
      json.extract! pricing, :id, :name, :description, :position, :free, :license_based, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id
    end if product_markup.product.respond_to?(:product_pricings)
  end
end if product_markup.product.present?

json.organization do
  json.id product_markup.organization.id
  json.name product_markup.organization.name
end if product_markup.organization.present?
