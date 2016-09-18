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

  # TODO: add dependencies
  s.add_dependency 'mno-enterprise-core', s.version

  # Views
  # TODO: get rid of the haml dependency? and replace with html template
  s.add_runtime_dependency 'jbuilder', '~> 2.2.16'
  s.add_runtime_dependency 'haml', '~> 4.0'
  s.add_runtime_dependency 'coffee-rails', '~> 4.1'
  s.add_runtime_dependency 'health_check', '~> 1.5'
  s.add_runtime_dependency 'httparty', '~> 0.13.7'
  # Lock sprocket version
  s.add_dependency 'sprockets-rails', '~> 2.3'

  s.add_development_dependency 'intercom', '~> 3.5.4'
end
