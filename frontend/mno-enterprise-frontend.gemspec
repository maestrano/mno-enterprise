$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative '../core/lib/mno_enterprise/version.rb'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise-frontend"
  s.version     = MnoEnterprise::VERSION.to_s
  s.authors     = ["Arnaud Lachaume", "Olivier Brisse"]
  s.email       = ["developers@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise - Frontend"
  s.description = "Angular/Bootstrap frontend for MNOE"
  s.license     = "Apache-2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  # TODO: add dependencies
  s.add_dependency 'mno-enterprise-core', s.version
  s.add_dependency 'mno-enterprise-api', s.version

  s.add_dependency 'less-rails', '~> 2.7'
  s.add_dependency 'therubyracer', '~> 0.12'
  s.add_dependency 'haml-rails', '~> 0.9'
  # s.add_dependency 'coffee-rails', '~> 4.1'
  s.add_dependency 'jquery-rails', '~> 4.0'
  # s.add_dependency 'sprockets-rails', '~> 2.2'
  s.add_dependency 'ngannotate-rails', '~> 1.0'

  # Development: Rewrite routes for I18N
  s.add_dependency 'rack-rewrite'
end
