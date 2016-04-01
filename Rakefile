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

desc "Run all tests by default"
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

desc "Clean the whole repository by removing all the generated files"
task :clean do
  FileUtils.rm_rf("pkg")

  MNOE_GEMS.each do |gem_name|
    FileUtils.rm_f("#{gem_name}/Gemfile.lock")
    FileUtils.rm_rf("#{gem_name}/pkg")
    FileUtils.rm_rf("#{gem_name}/spec/dummy")
  end
end

namespace :gem do
  root    = File.expand_path('../', __FILE__)
  version = File.read("#{root}/MNOE_VERSION").strip
  tag     = "v#{version}"

  def for_each_gem(version)
    MNOE_GEMS.each do |gem_name|
      yield "pkg/mno-enterprise-#{gem_name}-#{version}.gem"
    end
    yield "pkg/mno-enterprise-#{version}.gem"
  end

  task :ensure_clean_state do
    unless `git status -s | grep -v 'MNOE_VERSION\\|CHANGELOG\\|Gemfile.lock'`.strip.empty?
      abort "[ABORTING] `git status` reports a dirty tree. Make sure all changes are committed"
    end

    unless ENV['SKIP_TAG'] || `git tag | grep '^#{tag}$'`.strip.empty?
      abort "[ABORTING] `git tag` shows that #{tag} already exists. Has this version already\n"\
            "           been released? Git tagging can be skipped by setting SKIP_TAG=1"
    end
  end

  desc 'Bump all versions to match MNOE_VERSION'
  task :update_version do
    file = File.join(root, 'core/lib/mno_enterprise/version.rb')
    ruby = File.read(file)

    ruby.gsub!(/^(\s*)VERSION(\s*)= '.*?'$/, "\\1VERSION = '#{version}'")
    raise "Could not insert VERSION in #{file}" unless $1

    File.open(file, 'w') { |f| f.write ruby }
  end

  desc "Build all mnoe gems"
  task build: [:clean, :update_version] do
    pkgdir = File.expand_path("../pkg", __FILE__)
    FileUtils.mkdir_p pkgdir

    MNOE_GEMS.each do |gem_name|
      Dir.chdir(gem_name) do
        sh "gem build mno-enterprise-#{gem_name}.gemspec"
        mv "mno-enterprise-#{gem_name}-#{version}.gem", pkgdir
      end
    end

    sh "gem build mno-enterprise.gemspec"
    mv "mno-enterprise-#{version}.gem", pkgdir
  end

  desc "Install all mnoe gems"
  task install: :build do
    for_each_gem(version) do |gem_path|
      Bundler.with_clean_env do
        sh "gem install #{gem_path}"
      end
    end
  end

  task :bundle do
    sh 'bundle check'
  end

  task :commit do
    File.open('pkg/commit_message.txt', 'w') do |f|
      f.puts "# Preparing for #{version} release\n"
      f.puts
      f.puts "# UNCOMMENT THE LINE ABOVE TO APPROVE THIS COMMIT"
    end

    sh "git add -u . && git commit --verbose --template=pkg/commit_message.txt"
    rm_f "pkg/commit_message.txt"
  end

  # Tag commit
  task :tag do
    sh "git tag -m '#{tag} release' #{tag}"
    sh "git push --tags"
  end

  # Push to rubygems
  task push: :build do
    for_each_gem(version) do |gem_path|
      sh "gem push '#{gem_path}'"
    end
  end

  desc "Prepare the release"
  task :prep_release => %w(ensure_clean_state build)

  desc "Release all gems to rubygems and create a tag"
  task :release => %w(ensure_clean_state build bundle commit tag push)
end
