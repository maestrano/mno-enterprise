json.extract! app, :id, :nid, :name, :tiny_description

if app.logo
  json.logo app.logo.to_s
end
