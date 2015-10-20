begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

begin
  require 'mno_enterprise/testing_support/common_rake'
rescue LoadError
  raise "Could not find mno_enterprise/testing_support/common_rake. You need to run this command using Bundler."
  exit
end


task default: :test

desc "Runs all tests in all Mnoe engines"
task :test do
  Rake::Task['test_app'].invoke
  %w(api core frontend).each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      system("bundle exec rspec") or exit!(1)
    end
  end
end

desc "Generates a dummy app for testing for every Mnoe engine"
task :test_app do
  require File.expand_path('../core/lib/generators/mno_enterprise/install/install_generator', __FILE__)
  %w(api core frontend).each do |engine|
    ENV['LIB_NAME'] = "mno-enterprise-#{engine}"
    ENV['DUMMY_PATH'] = File.expand_path("../#{engine}/spec/dummy", __FILE__)
    # Rake::Task['common:test_app'].execute
    Rake::Task['mno_enterprise:testing:create_dummy_app'].execute
  end
end

desc "clean the whole repository by removing all the generated files"
task :clean do
  # puts "Deleting sandbox..."
  # FileUtils.rm_rf("sandbox")
  puts "Deleting pkg directory.."
  FileUtils.rm_rf("pkg")

  %w(api core frontend).each do |gem_name|
    puts "Cleaning #{gem_name}:"
    puts "  Deleting #{gem_name}/Gemfile.lock"
    FileUtils.rm_f("#{gem_name}/Gemfile.lock")
    puts "  Deleting #{gem_name}/pkg"
    FileUtils.rm_rf("#{gem_name}/pkg")
    puts "  Deleting #{gem_name}'s dummy application"
    Dir.chdir("#{gem_name}/spec") do
      FileUtils.rm_rf("dummy")
    end
  end
end
