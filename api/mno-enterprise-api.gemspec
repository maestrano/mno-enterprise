$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative '../core/lib/mno_enterprise/version.rb'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise-api"
  s.version     = MnoEnterprise::VERSION.to_s
  s.authors     = ["Arnaud Lachaume", "Olivier Brisse"]
  s.email       = ["developers@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise - API"
  s.description = "Maestrano Enterprise - essentials API"
  s.license     = "Apache-2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = '>= 2.3.1'

  # TODO: add dependencies
  s.add_dependency 'mno-enterprise-core', s.version

  # Views
  # TODO: get rid of the haml dependency? and replace with html template
  s.add_runtime_dependency 'jbuilder', '~> 2.2.16'
  s.add_runtime_dependency 'haml', '~> 4.0'
  s.add_runtime_dependency 'coffee-rails', '~> 4.1'
  s.add_runtime_dependency 'health_check', '~> 2.4'
  s.add_runtime_dependency 'httparty', '~> 0.13.7'
  s.add_runtime_dependency 'credit_card_validations', '~> 3.4.0'
  # Lock sprocket version
  s.add_dependency 'sprockets-rails', '~> 2.3'

  s.add_development_dependency 'intercom', '~> 3.5.4'

  # Omniauth authentication strategies
  s.add_development_dependency 'omniauth-openid', '~> 1.0'
  s.add_development_dependency 'omniauth-linkedin-oauth2', '~> 0.1.5'
  s.add_development_dependency 'omniauth-google-oauth2', '~> 0.2.6'
  s.add_development_dependency 'omniauth-facebook', '~> 2.0.1'
  # TODO make gem works with rails 4
  # s.add_runtime_dependency 'active_record_openid_store', '~> 0.1.5'
end
