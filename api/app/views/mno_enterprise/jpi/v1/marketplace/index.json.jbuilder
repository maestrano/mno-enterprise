json.cache! ['marketplace', @last_modified, I18n.locale] do
  json.products do
    json.array!(@products) do |product|
      json.extract! product, :id, :name, :logo, :local, :tiny_description
      json.app_id product.app&.id
      json.categories product.categories&.map(&:name)
    end
  end

  json.categories @categories
end
