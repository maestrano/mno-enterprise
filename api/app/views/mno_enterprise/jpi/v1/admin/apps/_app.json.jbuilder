json.extract! app, :id, :nid, :name, :tiny_description, :categories

if app.logo
  json.logo app.logo.to_s
end
