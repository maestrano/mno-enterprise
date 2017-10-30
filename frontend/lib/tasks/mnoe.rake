require 'fileutils'

# TODO: display more info about versioning
# TODO: DRY frontend/admin tasks + specs
namespace :mnoe do
  #================================================================
  # Helper methods
  #================================================================
  def admin_panel_installed?
    File.foreach('yarn.lock').grep(/mnoe-admin-panel/).any?
  end

  def summary
    puts '==> Your project has been upgraded'
    puts '- mno-enterprise has been updated'
    puts '- mno-enterprise-angular has been updated and the frontend rebuilt'
    puts '- mnoe-admin-panel has been updated and the admin-panel rebuilt' if admin_panel_installed?
    puts
    puts 'To commit your changes:'
    puts '- Commit the packages:'
    puts '  $ git add -u *.lock'
    puts '  $ git commit -m "Bump packages"'
    puts '- Commit the build:'
    puts '  $ git add public/dashboard public/admin'
    puts '  $ git commit -m "Rebuild frontend"'
  end

  #================================================================
  # Tasks
  #================================================================
  desc 'Perform a full upgrade and rebuild of this mnoe project'
  task :update_all do
    puts '==> Updating the mno-enterprise gem'
    sh 'bundle update mno-enterprise --quiet'

    puts '==> Updating and rebuilding the Dashboard'
    Rake::Task['mnoe:frontend:update'].invoke

    if admin_panel_installed?
      puts '==> Updating and rebuilding the Admin Panel'
      Rake::Task['mnoe:admin:update'].invoke
    end

    summary
  end
end
