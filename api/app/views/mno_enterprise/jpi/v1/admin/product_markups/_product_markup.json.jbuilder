json.extract! product_markup, :id, :percentage, :created_at

json.product do
  json.id product_markup.product.id
  json.name product_markup.product.name
end if product_markup.product.present?

json.organization do
  json.id product_markup.organization.id
  json.name product_markup.organization.name
end if product_markup.organization.present?
