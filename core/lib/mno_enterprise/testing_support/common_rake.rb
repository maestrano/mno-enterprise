unless defined?(MnoEnterprise::Generators::InstallGenerator)
  require 'generators/mno_enterprise/install/install_generator'
end

require 'generators/mno_enterprise/dummy/dummy_generator'

namespace :mno_enterprise do
  namespace :testing do
    desc "Generate a dummy app for testing"
    task :create_dummy_app do
      require "#{ENV['LIB_NAME']}"

      ENV["RAILS_ENV"] = 'test'

      MnoEnterprise::DummyGenerator.start %W[--quiet --lib_name=#{ENV['LIB_NAME']} --database=#{ENV['DB'].presence || 'sqlite3'}]
      MnoEnterprise::Generators::InstallGenerator.start %w[--quiet --skip-rspec --skip-sprite --skip-factory-girl --skip-application-config --skip-frontend --skip-admin]
    end
  end
end
