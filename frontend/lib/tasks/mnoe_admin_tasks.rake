require 'fileutils'

#=============================================
# Enterprise Express Tasks
#=============================================
# Enterprise Express related tasks
namespace :mnoe do
  namespace :admin do
    admin_dist_folder = "public/admin"
    frontend_tmp_folder = 'tmp/build/admin'
    frontend_orig_folder = 'frontend-admin'

    # Use bundled gulp
    gulp = "./node_modules/.bin/gulp"

    desc "Install dependencies"
    task :install_dependencies do
      # Install required tools
      sh("which bower || npm install -g bower")
    end


    desc "Setup the Enterprise Express Admin Dashboard"
    task install: :install_dependencies do
      # Build the admin
      Rake::Task['mnoe:admin:dist'].invoke
    end

    desc "Rebuild the Enterprise Express Admin Dashboard"
    task :dist do
      # Prepare the build folder
      Rake::Task['mnoe:admin:prepare_build_folder'].execute

      # Build frontend using Gulp
      Dir.chdir(frontend_tmp_folder) do
        sh "npm install"
        sh "bower install"
        sh gulp
      end

      # Ensure distribution folder exists
      mkdir_p admin_dist_folder

      # Cleanup previously compiled files
      Dir.glob("#{admin_dist_folder}/{styles,scripts}/app-*.{css,js}").each do |f|
        rm_f f
      end

      # Copy assets to public
      cp_r("#{frontend_tmp_folder}/dist/.", "#{admin_dist_folder}/")

      # Clear tmp cache in development - recompile assets otherwise
      if Rails.env.development? || Rails.env.test?
        Rake::Task['tmp:cache:clear'].execute
      else
        Rake::Task['assets:precompile'].execute
      end
    end

    desc "Reset the admin build folder"
    task :prepare_build_folder do
      # Reset tmp folder from mno-enterprise/frontend-admin source
      rm_rf "#{admin_dist_folder}"
      rm_rf "#{frontend_tmp_folder}"
      mkdir_p frontend_tmp_folder
      cp_r(File.join(Gem.loaded_specs["mno-enterprise"].full_gem_path, "#{frontend_orig_folder}/."), "#{frontend_tmp_folder}/")
    end
  end
end
