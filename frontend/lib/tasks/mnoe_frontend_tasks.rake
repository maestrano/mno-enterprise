require 'fileutils'

#=============================================
# Enterprise Express Tasks
#=============================================
# Enterprise Express related tasks
namespace :mnoe do
  namespace :frontend do
    frontend_dist_folder = "public/dashboard"
    frontend_project_folder = 'frontend'
    frontend_tmp_folder = 'tmp/build/frontend'
    frontend_bower_folder = 'bower_components/mno-enterprise-angular'

    # Use bundled gulp
    gulp = "./node_modules/.bin/gulp"

    desc "Install dependencies"
    task :install_dependencies do
      # Install required tools
      sh("which bower || npm install -g bower")
    end

    desc "Setup the Enterprise Express frontend"
    task install: :install_dependencies do
      # TODO: replace with a frontend download task without using bower
      # Setup bower and dependencies
      bower_src = File.join(File.expand_path(File.dirname(__FILE__)),'templates','bower.json')
      cp(bower_src, 'bower.json')
      sh("bower install --quiet")

      # Create frontend override folder
      mkdir_p(frontend_project_folder)
      touch "#{frontend_project_folder}/.keep"

      # Bootstrap override folder
      # Replace relative image path by absolute path in the LESS files
      mkdir_p("#{frontend_project_folder}/src/app/stylesheets")
      ['src/app/stylesheets/theme.less','src/app/stylesheets/variables.less'].each do |path|
        next if File.exists?("#{frontend_project_folder}/#{path}")

        # Generate file from template
        cp("#{frontend_bower_folder}/#{path}","#{frontend_project_folder}/#{path}")

        # Replace image relative path
        content = File.read("#{frontend_project_folder}/#{path}")
        File.open("#{frontend_project_folder}/#{path}", 'w') do |f|
          f << content.gsub("../images", File.join(frontend_dist_folder.gsub("public",""),"images"))
        end
      end

      # Setup theme previewer working files so we can safely include
      # them in main.less
      ['theme-previewer-tmp.less','theme-previewer-published.less'].each do |filename|
        FileUtils.touch(File.join(Rails.root,"frontend/src/app/stylesheets/#{filename}"))
      end

      # Create custom fonts files so we can safely include them in main.less
      frontend_font_folder = File.join(frontend_project_folder, 'src/fonts')
      unless File.exists?(File.join(frontend_font_folder, 'font-faces.less'))
        font_src = File.join(File.expand_path(File.dirname(__FILE__)),'templates','font-faces.less')

        mkdir_p(frontend_font_folder)
        cp(font_src, frontend_font_folder)
      end

      # Build the frontend
      Rake::Task['mnoe:frontend:dist'].invoke
      #Rake::Task['assets:precompile'].invoke
    end

    desc "Rebuild the Enterprise Express frontend"
    task :dist do
      # Prepare the build folder
      Rake::Task['mnoe:frontend:prepare_build_folder'].execute

      # Build frontend using Gulp
      Dir.chdir(frontend_tmp_folder) do
        sh "npm install"
        sh gulp
        sh "#{gulp} less-concat"
      end

      # Ensure distribution folder exists
      mkdir_p frontend_dist_folder

      # Cleanup previously compiled files
      Dir.glob("#{frontend_dist_folder}/{styles,scripts}/app-*.{css,js}").each do |f|
        rm_f f
      end

      # Copy assets to public
      cp_r("#{frontend_tmp_folder}/dist/.","#{frontend_dist_folder}/")

      # Copy bower_components to public (used by live previewer)
      cp_r("#{frontend_tmp_folder}/bower_components","#{frontend_dist_folder}/")

      # Clear tmp cache in development - recompile assets otherwise
      if Rails.env.development? || Rails.env.test?
        Rake::Task['tmp:cache:clear'].execute
      else
        Rake::Task['assets:precompile'].execute
      end
    end

    desc "Rebuild the Live Previewer Style"
    task :rebuild_previewer_style do
      # Prepare the build folder
      Rake::Task['mnoe:frontend:prepare_build_folder'].execute

      # Build the previewer stylesheet
      Dir.chdir(frontend_tmp_folder) do
        sh "npm install"
        sh "#{gulp} less-concat"
      end

      # Copy stylesheet to public
      cp("#{frontend_tmp_folder}/dist/styles/theme-previewer.less","#{frontend_dist_folder}/styles/")

      # Copy bower_components to public (used by live previewer)
      cp_r("#{frontend_tmp_folder}/bower_components","#{frontend_dist_folder}/")

      # Clear tmp cache in development
      if Rails.env.development? || Rails.env.test?
        Rake::Task['tmp:cache:clear'].execute
      end
    end

    desc "Reset the frontend build folder and apply local customisations"
    task :prepare_build_folder do
      # Ensure frontend is downloaded
      sh("[ -d #{frontend_bower_folder} ] || bower install")

      # Reset tmp folder from mno-enterprise-angular source
      rm_rf "#{frontend_tmp_folder}/src"
      rm_rf "#{frontend_tmp_folder}/e2e"
      mkdir_p frontend_tmp_folder
      cp_r("#{frontend_bower_folder}/.","#{frontend_tmp_folder}/")

      # Apply frontend customisations
      cp_r("#{frontend_project_folder}/.","#{frontend_tmp_folder}/")
    end

    desc "Update the frontend and rebuild it"
    task :update do
      # Run bower to get a new version of the frontend
      sh "bower update"

      # Rebuild the frontend
      Rake::Task['mnoe:frontend:dist'].execute
    end
  end
end
