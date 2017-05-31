$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative 'lib/mno_enterprise/version.rb'

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

  s.add_dependency 'rails', '~> 4.2', '>= 4.2.0'
  s.add_dependency "her", "~> 0.7.3"
  s.add_dependency "faraday_middleware", "~> 0.10.0"
  s.add_dependency "httparty", '~> 0.11'
  s.add_dependency 'countries', '~> 0.11.3'
  s.add_dependency 'jwt', '~> 1.4'
  s.add_dependency 'deepstruct', '~> 0.0.7'
  s.add_dependency 'prawn', '~> 2.0', '>= 2.0.1'
  s.add_dependency 'prawn-table', '~> 0.2.1'
  s.add_dependency 'money', '~> 6.5', '>= 6.5.1'

  # Authentication & Authorization
  s.add_dependency 'devise', '~> 3.0'
  s.add_dependency 'cancancan', '~> 1.10'
  s.add_dependency 'omniauth', '~> 1.3.1'

  # Email
  # TODO: remove in 3.2, left for backward compatibility
  s.add_dependency 'mandrill-api', '~> 1.0', '>= 1.0.53'

  # Markdown parsing
  s.add_dependency 'redcarpet', '~> 3.3', '>= 3.3.3'
  s.add_dependency 'sanitize', '~> 4.0'

  # Configuration & Settings
  # Manage configuration via environment variables
  # TODO: only needed for development?
  s.add_dependency 'figaro'
  # Config files per environment
  s.add_dependency 'config', '~> 1.4.0'

  # Emailing
  # s.add_development_dependency 'mandrill-api', '~> 1.0.53'
  s.add_development_dependency 'sparkpost', '~> 0.1.4'
end
