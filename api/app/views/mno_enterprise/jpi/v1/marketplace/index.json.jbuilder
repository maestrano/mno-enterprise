json.cache! ['marketplace', @last_modified, I18n.locale] do
  json.products do
    json.array!(@products) do |product|
      json.extract! product, :id, :nid, :name, :logo, :local, :values_attributes
      json.app_id product.app&.id
      json.categories product.product_categories
    end
  end

  json.categories @categories
end
