json.cache! ['marketplace', @last_modified, I18n.locale] do
  json.categories @categories
  json.apps @apps, partial: 'app', as: :app
  json.products @products, partial: 'product', as: :product
end
