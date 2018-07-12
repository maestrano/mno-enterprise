json.product do
  json.partial! 'product', product: @product

  json.product_pricings @product.product_pricings do |product_pricing|
    json.partial! 'mno_enterprise/jpi/v1/admin/product_pricing/product_pricing', product_pricing: product_pricing
  end
end
