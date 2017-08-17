json.id product_instance.id
product_instance.product.tap do |a|
  json.product_id a.id
  json.product_name a.name
  json.product_nid a.nid
  json.external_nid a.external_id
  json.logo a.logo
end
