Config.setup do |config|
  config.const_name = "Settings"
  # Settings from ENV variables overwrite
  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = '__'
  config.env_converter = :downcase
  config.env_parse_values = true
end

# Use the template as default settings
default = File.expand_path("../../../lib/generators/mno_enterprise/install/templates/config/settings.yml", __FILE__)
Settings.prepend_source!(default)
Settings.reload!
