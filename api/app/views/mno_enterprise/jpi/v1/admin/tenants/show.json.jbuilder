json.tenant do
  # Expose the full settings (not just MnoHub ones)
  json.frontend_config Settings.to_hash
  json.domain @tenant.domain
end
