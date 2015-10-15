$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require File.expand_path('../../core/lib/mno_enterprise/version', __FILE__)
version = MnoEnterprise::VERSION.to_s

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise-api"
  s.version     = version
  s.authors     = ["Arnaud Lachaume"]
  s.email       = ["arnaud.lachaume@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise - API"
  s.description = "Maestrano Enterprise - essentials API"
  s.license     = "Maestrano Enterprise License V1"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  # TODO: add dependencies
  s.add_dependency 'mno-enterprise-core', version

  # Views
  # TODO: get rid of the haml dependency? and replace with html template
  s.add_dependency 'jbuilder', '~> 2.2.12'
  s.add_dependency 'haml', '~> 4.0.6'
  s.add_dependency 'coffee-rails', '~> 4.1.0'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
end
