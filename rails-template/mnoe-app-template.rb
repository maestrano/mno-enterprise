# Match the mno-enterprise rails dependency
RAILS_REQUIREMENT = ["~> 4.2", ">= 4.2.0"]

# Local path to the gem if using a local template
MNOE_DEV_PATH = File.expand_path("..", File.dirname(__FILE__)) unless __FILE__ =~ %r{\Ahttps?://}

def apply_template!
  assert_compatible_rails_version
  assert_valid_options

  @mnoe_version = ask("Choose mno-enterprise version:", limited_to: available_mnoe_versions).to_sym

  # Rebuild the Gemfile from scratch
  template 'templates/Gemfile', 'Gemfile', force: true

  copy_file 'files/gitignore', '.gitignore', force: true
  template 'templates/ruby-version.tt', '.ruby-version'

  # Add test tasks
  rakefile("test.rake") do <<-EOF
  # Don't crash in production
  begin
    require 'bundler/audit/task'
    require 'rubocop/rake_task'
    require 'rspec/core/rake_task'

    Bundler::Audit::Task.new
    RuboCop::RakeTask.new
  rescue LoadError
  end

  namespace :test do
    desc 'Run all tests'
    task all: :environment do
      Rake::Task['bundle:audit'].invoke
      Rake::Task['brakeman:run'].invoke
      Rake::Task['rubocop'].invoke
    end
  end

  task :test do
    Rake::Task['test:all'].invoke
  end

  # Running `rake` runs all the tests.
  task default: :test
  EOF
  end

  # Create uat environment
  copy_file File.join(destination_root, 'config/environments/production.rb'), 'config/environments/uat.rb'

  # secrets
  append_to_file 'config/secrets.yml' do
    'uat:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>'
  end

  after_bundle do
    #
    # Cleanup
    #
    remove_dir 'app/views'
    remove_dir 'app/mailers'
    remove_dir 'test'

    update_application_rb

    # Setup test environment
    generate 'rspec:install'
    run 'brakeman --rake'
    run 'rubocop --auto-gen-config'

    remove_file '.rubocop.yml'
    copy_file 'files/rubocop.yml', '.rubocop.yml'

    # Install mnoe
    generate 'mno_enterprise:install'

    # Git: Initialize
    # ==================================================
    if yes?("Do you want to initalize a git repository for this new app?")
      git :init
      git add: "."
      git commit: "-a -m 'Initial commit'"
    end
  end
end

# ==================================================
# Here be dragons. Thou art forewarned
# ==================================================

require 'shellwords'

#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
# Thanks @mattbrictson!
#
def current_directory
  @current_directory ||=
      if __FILE__ =~ %r{\Ahttps?://}
        tempdir = Dir.mktmpdir("mno-enterprise-")
        at_exit { FileUtils.remove_entry(tempdir) }
        git :clone => [
                "--quiet",
                "https://github.com/maestrano/mno-enterprise.git",
                tempdir
            ].map(&:shellescape).join(" ")

        File.join(tempdir, 'rails-template')
      else
        File.expand_path(File.dirname(__FILE__))
      end
end

# Add the current directory to the path Thor uses
# to look up files
def source_paths
  Array(super) + [current_directory]
end

# ==================================================
# Monkey patched from Rails::Generators::AppBase
# ==================================================

# Only use gems list for database (we manage the rest ourself)
def gemfile_entries
  [mnoe_gemfile_entry,
   database_gemfile_entry,
   assets_gemfile_entry,
   @extra_entries].flatten.find_all(&@gem_filter)
end

def mnoe_gemfile_entry
  gems = []

  case @mnoe_version
  when :stable
    gems << GemfileEntry.version('mno-enterprise',
                                 '~> 3.0',
                                 "Bundle edge Mnoe instead: gem 'mno-enterprise', github: 'maestrano/mno-enterprise'")
  when :edge
    gems << GemfileEntry.github('mno-enterprise', 'maestrano/mno-enterprise')
  when :dev
    gems << GemfileEntry.path('mno-enterprise', MNOE_DEV_PATH)
  end

  # Emailing
  gems << GemfileEntry.new('mandrill-api', '~> 1.0.53', 'Emailing', {}, true)
  gems << GemfileEntry.new('sparkpost', '~> 0.1.4', nil, {}, true)

  gems << GemfileEntry.new('intercom', '~> 3.5.4', 'Enable Intercom', {}, true)

  # Omniauth
  gems << GemfileEntry.new('omniauth-openid', '~> 1.0', 'Omniauth authentication strategies', {}, true)
  gems << GemfileEntry.new('openid-store-redis', '~> 1.0', nil, {}, true)
  gems << GemfileEntry.new('omniauth-linkedin-oauth2', '~> 0.1.5', nil, {}, true)
  gems << GemfileEntry.new('omniauth-google-oauth2', '~> 0.2.6', nil, {}, true)
  gems << GemfileEntry.new('omniauth-facebook', '~> 2.0.1', nil, {}, true)

  gems << GemfileEntry.new('redis-rails', '~> 5.0.2', 'Redis cache', {}, true)

  gems
end

# ==================================================

# stable: latest version available on rubygems
# edge:   master branch of the mno-enterprise repository
# dev:    local mnoe-enteprise checkout
def available_mnoe_versions
  versions = %w[stable edge]
  versions << 'dev' if defined?(MNOE_DEV_PATH)
  versions
end

# Ensure we're using a compatible Rails version
def assert_compatible_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# Exit if the user has used invalid generator options.
def assert_valid_options
  valid_options = {
    skip_gemfile: false,
    skip_bundle: false,
    skip_git: false
  }
  valid_options.each do |key, expected|
    next unless options.key?(key)
    actual = options[key]
    unless actual == expected
      fail Rails::Generators::Error, "Unsupported option: #{key}=#{actual}"
    end
  end
end

def update_application_rb
  template = %q(
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.view_specs false
      g.helper_specs false
    end

    # Mail delivery settings
    config.action_mailer.delivery_method = :smtp

    # Cache Store
    # Add the redis-rails gem to use redis
    # config.cache_store = if ENV['REDIS_URL'].present?
    #                        [:redis_store, File.join(ENV['REDIS_URL'], 'cache')]
    #                      else
    #                        :memory_store
    #                      end

    # STDOUT logging for Rails 4
    # For Rails 5 see https://github.com/heroku/rails_12factor#rails-5-and-beyond
    if ENV["RAILS_LOG_TO_STDOUT"].present?
      log_level     = ([(ENV['LOG_LEVEL'] || ::Rails.application.config.log_level).to_s.upcase, "INFO"] & %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]).compact.first
      logger        = ::ActiveSupport::Logger.new(STDOUT)
      logger        = ActiveSupport::TaggedLogging.new(logger) if defined?(ActiveSupport::TaggedLogging)
      logger.level  = ::ActiveSupport::Logger.const_get(log_level)
      config.logger = logger

      STDOUT.sync = true
    end)
  application template
end

apply_template!
