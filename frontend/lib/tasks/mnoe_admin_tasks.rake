require 'fileutils'
require 'erb'
require 'rake/clean'

#=============================================
# Enterprise Express Tasks
#=============================================
# Enterprise Express related tasks
namespace :mnoe do
  namespace :admin do
    # Default version
    MNOE_ADMIN_PANEL_VERSION = '2.0'
    MNOE_ADMIN_PANEL_PKG = "git+https://git@github.com/maestrano/mnoe-admin-panel.git##{MNOE_ADMIN_PANEL_VERSION}"

    # Final build
    admin_panel_dist_folder = 'public/admin'
    # Local overrides
    admin_panel_project_folder = 'frontend-admin-panel'
    # Tmp build
    admin_panel_tmp_folder = 'tmp/build/admin_panel'
    # Frontend package
    ADMIN_PANEL_PKG_FOLDER = 'node_modules/mnoe-admin-panel'

    ## Helper methods
    def render_template(template_file, output_file, binding = nil)
      File.open(output_file, "w+") do |f|
        f.write(ERB.new(File.read(template_file)).result(binding))
      end
    end

    # Override the frontend bower.json with the locked versions
    def override_admin_dependencies
      resolved_version = resolve_dependencies
      unless resolved_version
        puts "No impac-angular override. Skipping"
        return
      end

      frontend_bower_file = File.join(ADMIN_PANEL_PKG_FOLDER, 'bower.json')
      File.exist?(frontend_bower_file) || raise("Frontend bower file not found.")

      # Override the bowerfile
      bower_regexp = /"impac-angular": (".*")/

      # TODO: refactor
      IO.write(frontend_bower_file, File.open(frontend_bower_file) do |f|
        f.read.gsub(bower_regexp) do |match|
          match.gsub!(Regexp.last_match(1), resolved_version)
        end
      end
      )
    end

    desc 'Setup the Enterprise Express Admin Panel'
    task :install do
      Rake::Task['mnoe:admin:add_package'].invoke

      Rake::Task['mnoe:admin:install_frontend'].invoke

      # Bootstrap frontend folder
      Rake::Task['mnoe:admin:bootstrap_override_folder'].invoke

      # Build the frontend
      Rake::Task['mnoe:admin:build'].invoke
    end

    desc 'Build/Rebuild the Enterprise Express Admin Panel'
    task :build do
      # Prepare the build folder
      Rake::Task['mnoe:admin:prepare_build_folder'].execute

      # Build frontend using Gulp
      Dir.chdir(admin_panel_tmp_folder) do
        sh 'yarn install'
        sh 'bower install'
        sh 'npm run build'
      end

      # Ensure distribution folder exists
      mkdir_p admin_panel_dist_folder

      # Cleanup previously compiled files
      Dir.glob("#{admin_panel_dist_folder}/{styles,scripts}/*.{css,js}").each do |f|
        rm_f f
      end

      # Copy assets to public
      cp_r("#{admin_panel_tmp_folder}/dist/.", "#{admin_panel_dist_folder}/")

      # Clear tmp cache in development - recompile assets otherwise
      if Rails.env.development? || Rails.env.test?
        Rake::Task['tmp:cache:clear'].execute
      else
        Rake::Task['assets:precompile'].execute
      end
    end

    # Alias to dist for backward compatibility
    task dist: :build

    desc 'Update the admin panel and rebuild it'
    task update: :install_dependencies do
      # Fetch new version of the packages
      sh 'yarn upgrade --ignore-scripts --ignore-engines'

      # Cleanup
      rm_rf "#{admin_panel_tmp_folder}/bower_components"

      # Rebuild the admin panel
      Rake::Task['mnoe:admin:build'].execute
    end

    # Install dependencies
    # TODO: DRY
    task :install_dependencies do
      unless system('which yarn')
        puts 'Yarn executable was not detected in the system.'
        puts 'Download Yarn at https://yarnpkg.com/en/docs/install'
        raise
      end

      # Install required tools
      sh('which bower || yarn global add bower')
    end

    # Add 'mnoe-admin-panel' to package.json
    task :add_package do
      sh "yarn add  --ignore-scripts --ignore-engines #{MNOE_ADMIN_PANEL_PKG}"
    end

    task install_frontend: [:install_dependencies] do
      # Fetch the packages
      sh('yarn install --ignore-scripts --ignore-engines')
    end

    # Create & populate the admin panel override folder
    task :bootstrap_override_folder do
      # Create admin panel override folder
      mkdir_p(admin_panel_project_folder)
      touch "#{admin_panel_project_folder}/.keep"

      # Bootstrap override folder
      # Replace relative image path by absolute path in the LESS files
      mkdir_p("#{admin_panel_project_folder}/src/app/stylesheets")
      %w(src/app/stylesheets/theme.less src/app/stylesheets/variables.less).each do |path|
        next if File.exist?("#{admin_panel_project_folder}/#{path}")

        # Generate file from template
        cp("#{ADMIN_PANEL_PKG_FOLDER}/#{path}", "#{admin_panel_project_folder}/#{path}")

        # Replace image relative path
        content = File.read("#{admin_panel_project_folder}/#{path}")
        File.open("#{admin_panel_project_folder}/#{path}", 'w') do |f|
          f << content.gsub('../images', File.join(admin_panel_dist_folder.gsub('public', ''), 'images'))
        end
      end

      # Create custom fonts files so we can safely include them in main.less
      admin_panel_font_folder = File.join(admin_panel_project_folder, 'src/fonts')
      unless File.exist?(File.join(admin_panel_font_folder, 'font-faces.less'))
        font_src = File.join(__dir__,'templates','font-faces.less')

        mkdir_p(admin_panel_font_folder)
        cp(font_src, admin_panel_font_folder)
      end
    end

    # Reset the frontend build folder and apply local customisations
    task :prepare_build_folder do
      # Ensure frontend is downloaded
      Rake::Task['mnoe:admin:install_frontend'].invoke unless File.directory?(ADMIN_PANEL_PKG_FOLDER)

      # Override frontend dependencies
      puts "Locking frontend dependencies"
      override_admin_dependencies

      # Reset tmp folder from mnoe-admin-panel source
      rm_rf "#{admin_panel_tmp_folder}/src"
      rm_rf "#{admin_panel_tmp_folder}/e2e"
      mkdir_p admin_panel_tmp_folder
      cp_r("#{ADMIN_PANEL_PKG_FOLDER}/.", "#{admin_panel_tmp_folder}/")

      # Default variables to avoid breaking the build if there are new variables in the admin panel
      mv("#{admin_panel_tmp_folder}/src/app/stylesheets/variables.less", "#{admin_panel_tmp_folder}/src/app/stylesheets/variables-default.less")

      # Apply frontend customisations
      cp_r("#{admin_panel_project_folder}/.", "#{admin_panel_tmp_folder}/")
      # Defaults the enterprise logo to the Login logo
      unless File.exist?("#{admin_panel_project_folder}/src/images/main-logo.png")
        cp('app/assets/images/mno_enterprise/main-logo.png', "#{admin_panel_tmp_folder}/src/images/") if File.exist?('app/assets/images/mno_enterprise/main-logo.png')
      end
    end

    desc 'Remove all generated files'
    task :clean do
      clean = FileList[admin_panel_tmp_folder, admin_panel_dist_folder, ADMIN_PANEL_PKG_FOLDER, 'node_modules/.yarn-integrity']
      Rake::Cleaner.cleanup_files(clean)
    end
  end
end
