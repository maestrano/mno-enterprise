$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative 'core/lib/mno_enterprise/version.rb'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mno-enterprise"
  s.version     = MnoEnterprise::VERSION
  s.authors     = ["Arnaud Lachaume", "Olivier Brisse"]
  s.email       = ["developers@maestrano.com"]
  s.homepage    = "https://maestrano.com"
  s.summary     = "Maestrano Enterprise"
  s.description = "Maestrano Enterprise is your application marketplace, out of the box."
  s.license     = "Apache-2.0"

  s.required_ruby_version = '>= 2.3.1'

  # s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.files = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'mno-enterprise-core', s.version
  s.add_dependency 'mno-enterprise-api', s.version
  s.add_dependency 'mno-enterprise-frontend', s.version
end
