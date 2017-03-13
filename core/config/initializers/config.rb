Config.setup do |config|
  config.const_name = "Settings"
end

# Use the template as default settings
default = File.expand_path("../../../lib/generators/mno_enterprise/install/templates/config/settings.yml", __FILE__)
Settings.prepend_source!(default)
Settings.reload!
