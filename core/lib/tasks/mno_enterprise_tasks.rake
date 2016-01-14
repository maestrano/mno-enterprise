# desc "Explaining what the task does"
# task :mno_enterprise do
#   # Task goes here
# end

# /*\ WARNING /*\
# Make sure you never screw with that tasks. Ever.
# Otherwise, deletion of all database data may occur.
#
# This task is used by the Ansible automation scripts
# to automatically setup/seed the database or migrate it
#
namespace :db do
  desc 'Migrate the database or set it up'
  task :migrate_or_setup => :environment do
    if ActiveRecord::Migrator.current_version > 0
      Rake::Task['db:migrate'].invoke
    else
      Rake::Task['db:setup'].invoke
    end
  end
end

# Enterprise Express related tasks
namespace :mnoe do
  namespace :frontend do
    FRONTEND_PROJECT_FOLDER = 'frontend'
    FRONTEND_TMP_FOLDER = 'tmp/build/frontend'
    FRONTEND_BOWER_FOLDER = 'bower_components/mno-enterprise-angular'

    desc "Setup the Enterprise Express frontend"
    task :install do
      # Setup bower and dependencies
      bower_src = File.join(File.expand_path(File.dirname(__FILE__)),'templates','bower.json')
      cp(bower_src, 'bower.json', :verbose => true)
      sh("bower install")

      # Create frontend override folder
      mkdir_p FRONTEND_PROJECT_FOLDER
      touch "#{FRONTEND_PROJECT_FOLDER}/.gitkeep"

      # Build the frontend
      build_distribution
    end

    desc "Rebuild the Enterprise Express frontend"
    task :dist do
      build_distribution
    end

    def build_distribution
      # Reset tmp folder from mno-enterprise-angular source
      rm_rf "#{FRONTEND_BOWER_FOLDER}/src"
      rm_rf "#{FRONTEND_BOWER_FOLDER}/e2e"
      mkdir_p FRONTEND_BOWER_FOLDER
      cp_r("#{FRONTEND_BOWER_FOLDER}/.",FRONTEND_TMP_FOLDER)

      # Apply frontend customisations
      cp_r("#{FRONTEND_PROJECT_FOLDER}/.","#{FRONTEND_TMP_FOLDER}/")

      # Build frontend using Gulp
      Dir.chdir(FRONTEND_TMP_FOLDER) do
        sh "npm install"
        sh "npm run gulp"
      end

      # Distribute file in public
      cp_r("#{FRONTEND_TMP_FOLDER}/dist/.","public/")
    end
  end
end
