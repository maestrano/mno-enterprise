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

    desc "Setup the Enterprise Express frontend"
    task :install do
      # Install required tools
      sh("which bower || npm install -g bower")
      sh("which gulp || npm install -g gulp")
      sh("npm install -g gulp-util gulp-load-plugins del gulp-git")

      # Setup bower and dependencies
      bower_src = File.join(File.expand_path(File.dirname(__FILE__)),'templates','bower.json')
      cp(bower_src, 'bower.json')
      sh("bower install")

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
        sh "gulp"
        sh "gulp less-concat"
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
    end

    desc "Rebuild the Live Previewer Style"
    task :rebuild_previewer_style do
      # Prepare the build folder
      Rake::Task['mnoe:frontend:prepare_build_folder'].execute

      # Build the previewer stylesheet
      Dir.chdir(frontend_tmp_folder) do
        sh "npm install"
        sh "gulp less-concat"
      end

      # Copy stylesheet to public
      cp("#{frontend_tmp_folder}/dist/styles/theme-previewer.less","#{frontend_dist_folder}/styles/")

      # Copy bower_components to public (used by live previewer)
      cp_r("#{frontend_tmp_folder}/bower_components","#{frontend_dist_folder}/")
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
  end
end
