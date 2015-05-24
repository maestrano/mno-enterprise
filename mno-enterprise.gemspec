$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mno_enterprise/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise"
  s.version     = MnoEnterprise::VERSION
  s.authors     = ["Arnaud Lachaume"]
  s.email       = ["arnaud.lachaume@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise"
  s.description = "Maestrano Enterprise is your application marketplace, out of the box."
  s.license     = "Maestrano Enterprise License V1"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.0"
  s.add_dependency "her", "~> 0.7.3"
  s.add_dependency "devise", "~> 3.0"
  s.add_dependency "less-rails"
  s.add_dependency "therubyracer"
  s.add_dependency "jbuilder", '~> 2.2.12'
  s.add_dependency 'cancancan', '~> 1.10'
  s.add_dependency 'haml', '~> 4.0.6'
  s.add_dependency 'haml-rails', '~> 0.9.0'
  s.add_dependency 'coffee-rails', '~> 4.1.0'
  s.add_dependency 'countries', '~> 0.11.3'
  s.add_dependency 'jquery-rails', '~> 4.0.3'
  s.add_dependency 'jwt', '~> 1.4.1'
  s.add_dependency 'mandrill-api', '~> 1.0.53'
  s.add_dependency 'sprockets', '~> 2.12.3'
  s.add_dependency 'sprockets-rails', '~> 2.2.4'
  s.add_dependency 'deepstruct', '~> 0.0.7'
  s.add_dependency 'prawn', '~> 2.0.1'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
end
