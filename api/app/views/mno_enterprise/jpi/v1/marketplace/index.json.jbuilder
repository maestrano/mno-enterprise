json.cache! ['v1', 'marketplace'], expires_in: 20.minutes do
  json.categories @categories
  json.apps @apps, partial: 'app', as: :app
end
