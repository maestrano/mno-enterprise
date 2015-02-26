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
  s.description = "Maestrano Enteprise is your application marketplace, out of the box."
  s.license     = "Maestrano Enterprise License V1"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
