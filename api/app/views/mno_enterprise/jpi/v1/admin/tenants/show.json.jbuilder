json.tenant do
  # Expose the full settings (not just MnoHub ones)
  json.frontend_config Settings.to_hash
  json.domain @tenant.domain
  json.plugins_config @tenant.plugins_config
  json.config_schema Hash(MnoEnterprise::TenantConfig.json_schema)
  json.plugins_config_schema Hash(MnoEnterprise::PLUGINS_CONFIG_JSON_SCHEMA)
end
