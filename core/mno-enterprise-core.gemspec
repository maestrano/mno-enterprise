$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative 'lib/mno_enterprise/mno_enterprise_version.rb'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise-core"
  s.version     = MnoEnterprise::VERSION
  s.authors     = ["Arnaud Lachaume", "Olivier Brisse"]
  s.email       = ["developers@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise - Core functionnality"
  s.description = "Core functionnality of MNOE. This handles the core functionnality."
  s.license     = "Apache-2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = '>= 2.3.1'

  s.add_dependency 'rails', '~> 4.2', '>= 4.2.0'
  s.add_dependency 'httparty', '~> 0.11'
  s.add_dependency 'json_api_client', '~> 1.5.3'
  s.add_dependency 'countries', '~> 1.2.5'
  s.add_dependency 'jwt', '~> 1.4'
  s.add_dependency 'deepstruct', '~> 0.0.7'
  s.add_dependency 'prawn', '~> 2.0', '>= 2.0.1'
  s.add_dependency 'prawn-table', '~> 0.2.1'
  s.add_dependency 'money', '~> 6.5', '>= 6.5.1'
  s.add_dependency 'fastimage'

  # Authentication & Authorization
  s.add_dependency 'devise', '~> 3.0'
  s.add_dependency 'cancancan', '~> 1.10'
  s.add_dependency 'omniauth', '~> 1.3.1'

  # Markdown parsing
  s.add_dependency 'redcarpet', '~> 3.3', '>= 3.3.3'
  s.add_dependency 'sanitize', '~> 4.0'

  # Configuration & Settings
  # Config files per environment
  s.add_dependency 'config', '~> 1.4.0'

  # JSON Schema validation
  s.add_runtime_dependency 'json-schema'

  # I18n
  # 0.9.3 breaks TenantConfig as it won't load non available locales.
  # We still want to translate at least the `language` key to display the list
  # of available locales in the admin panel.
  # See: https://github.com/svenfuchs/i18n/pull/391
  s.add_runtime_dependency 'i18n', '0.9.1'

  # Emailing
  s.add_development_dependency 'mandrill-api', '~> 1.0', '>= 1.0.53'
  s.add_development_dependency 'sparkpost', '~> 0.1.4'

  # Platform
  s.add_development_dependency 'nex_client', '~> 0.17.0'
end
