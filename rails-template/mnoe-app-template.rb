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
   @extra_entries].flatten.find_all(&@gem_filter)
end

#
# Rebuild the Gemfile from scratch
remove_file 'Gemfile'
template 'templates/Gemfile', 'Gemfile'

remove_file '.gitignore'
copy_file 'files/gitignore', '.gitignore'

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
  generate 'spec:install'

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
