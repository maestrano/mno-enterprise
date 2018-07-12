json.extract! product_markup, :id, :percentage, :created_at

json.product do
  json.id product_markup.product.id
  json.name product_markup.product.name
  json.nid product_markup.product.nid

  json.product_pricings do
    json.array! product_markup.product.product_pricings.each do |pricing|
      json.partial! 'mno_enterprise/jpi/v1/admin/product_pricing/product_pricing', product_pricing: pricing
    end if product_markup.product.respond_to?(:product_pricings)
  end
end if product_markup.product.present?

json.organization do
  json.id product_markup.organization.id
  json.name product_markup.organization.name
end if product_markup.organization.present?
