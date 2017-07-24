json.cache! ['marketplace', @last_modified] do
  json.categories @categories
  json.apps @apps, partial: 'app', as: :app
end
