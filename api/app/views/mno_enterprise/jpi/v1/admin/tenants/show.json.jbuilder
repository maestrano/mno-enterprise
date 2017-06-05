json.tenant do
  # json.extract! @tenant, :frontend_config
  json.frontend_config Settings.to_hash
end
