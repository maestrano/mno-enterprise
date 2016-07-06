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

# Only use gems list for database (we manage the rest ourself)
def gemfile_entries
  [database_gemfile_entry,
   assets_gemfile_entry,
   @extra_entries].flatten.find_all(&@gem_filter)
end

#
# Rebuild the Gemfile from scratch
remove_file 'Gemfile'
template 'templates/Gemfile', 'Gemfile'

remove_file '.gitignore'
copy_file 'files/gitignore', '.gitignore'

# Add test tasks
rakefile("test.rake") do <<-EOF
# Don't crash in production
begin
  require 'bundler/audit/task'
  require 'rubocop/rake_task'
  require 'rspec/core/rake_task'

  Bundler::Audit::Task.new
  RuboCop::RakeTask.new
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

namespace :test do
  desc 'Run all tests'
  task all: :environment do
    Rake::Task['bundle:audit'].invoke
    Rake::Task['brakeman:run'].invoke
    Rake::Task['rubocop'].invoke
    Rake::Task['spec'].invoke
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

# Edit config/environments/*.rb
Dir["config/environments/*.rb"].each do |file|
  insert_into_file file, "\n  config.action_mailer.default_url_options = {host: 'localhost:7000'}\n", before: /^end$/
end

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

  application do <<-RUBY
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.view_specs false
      g.helper_specs false
    end
  RUBY
  end

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
