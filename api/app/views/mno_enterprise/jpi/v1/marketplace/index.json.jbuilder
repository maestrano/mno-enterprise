json.cache! ['marketplace', @last_modified, @org_id, I18n.locale] do
  json.categories @categories
  json.apps @apps, partial: 'app', as: :app
  json.products @products, partial: 'mno_enterprise/jpi/v1/products/product', as: :product
end
