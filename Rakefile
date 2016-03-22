require 'rake'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'mno_enterprise/testing_support/common_rake'
rescue LoadError
  raise "Could not find mno_enterprise/testing_support/common_rake. You need to run this command using Bundler."
end

MNOE_GEMS = %w(core api frontend)

task default: :test

desc "Runs all tests in all Mnoe engines"
task test: :test_app do
  MNOE_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      system("BUNDLE_GEMFILE=./Gemfile bundle exec rspec") or exit!(1)
    end
  end
end

desc "Generates a dummy app for testing for every Mnoe engine"
task :test_app do
  require File.expand_path('../core/lib/generators/mno_enterprise/install/install_generator', __FILE__)
  MNOE_GEMS.each do |engine|
    ENV['LIB_NAME'] = "mno-enterprise-#{engine}"
    ENV['DUMMY_PATH'] = File.expand_path("../#{engine}/spec/dummy", __FILE__)
    Rake::Task['mno_enterprise:testing:create_dummy_app'].execute
  end
end

desc "clean the whole repository by removing all the generated files"
task :clean do
  FileUtils.rm_rf("pkg")

  MNOE_GEMS.each do |gem_name|
    FileUtils.rm_f("#{gem_name}/Gemfile.lock")
    FileUtils.rm_rf("#{gem_name}/pkg")
    FileUtils.rm_rf("#{gem_name}/spec/dummy")
  end
end
