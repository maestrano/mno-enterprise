json.cache! ['marketplace', @last_modified, I18n.locale] do
  json.products do
    json.array!(@products) do |product|
      json.extract! product, :id, :name, :logo, :local
    end
  end
end
