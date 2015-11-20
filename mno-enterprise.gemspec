$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require File.expand_path('../core/lib/mno_enterprise/version', __FILE__)
version = MnoEnterprise::VERSION.to_s

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise"
  s.version     = version
  s.authors     = ["Arnaud Lachaume"]
  s.email       = ["arnaud.lachaume@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise"
  s.description = "Maestrano Enterprise is your application marketplace, out of the box."
  s.license     = "Maestrano Enterprise License V1"

  # s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.files = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'mno-enterprise-core', version
  s.add_dependency 'mno-enterprise-api', version
  s.add_dependency 'mno-enterprise-frontend', version

  # TODO: move? DRY to common dev dependencies
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
end
