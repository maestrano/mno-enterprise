json.cache! ['marketplace', @last_modified, I18n.locale] do
  json.products do
    json.array!(@products) do |product|
      json.extract! product, :id, :name, :logo, :local
      json.app_id product.app&.id
    end
  end
end
