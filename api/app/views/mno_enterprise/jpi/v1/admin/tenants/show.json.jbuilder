json.tenant do
  # Expose the full settings (not just MnoHub ones)
  json.frontend_config Settings.to_hash
  json.domain @tenant.domain
  json.plugins_config @tenant.plugins_config
  json.config_schema Hash(MnoEnterprise::TenantConfig.json_schema)
  json.plugins_config_schema Hash(MnoEnterprise::PLUGINS_CONFIG_JSON_SCHEMA)
  json.app_management @tenant.metadata[:app_management] || "marketplace"
  json.organization_credit_management @tenant.metadata[:can_manage_organization_credit]
  json.tenant_organization_id @tenant.tenant_company.id
end
