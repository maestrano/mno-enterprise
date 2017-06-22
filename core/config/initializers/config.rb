Config.setup do |config|
  config.const_name = "Settings"
  # Settings from ENV variables overwrite
  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = '__'
  config.env_converter = :downcase
  config.env_parse_values = true
end

# Use the JSON Schema as default settings
Settings.prepend_source!(MnoEnterprise::TenantConfig.to_hash)
Settings.reload!
