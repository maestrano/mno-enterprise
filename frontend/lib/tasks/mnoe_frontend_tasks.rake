require 'fileutils'
require 'erb'
require 'rake/clean'

#=============================================
# Enterprise Express Tasks
#=============================================
# Enterprise Express related tasks
namespace :mnoe do
  namespace :frontend do
    # Default version
    MNOE_ANGULAR_VERSION = "2.0"
    IMPAC_ANGULAR_VERSION = "v1.5.x"

    # Final build
    frontend_dist_folder = "public/dashboard"

    # Local overrides
    frontend_project_folder = 'frontend'

    # Tmp build
    frontend_tmp_folder = 'tmp/build/frontend'

    # Frontend package
    FRONTEND_PKG_FOLDER = 'node_modules/mno-enterprise-angular'
    PKG_FILE = 'package.json'

    # Use bundled commands
    GULP_CMD = "./node_modules/.bin/gulp"
    WIREDEP_CMD = "./node_modules/wiredep-cli/wiredep-cli.js"
    LESSC_CMD = "./node_modules/less/bin/lessc"

    #================================================================
    # Helper methods
    #================================================================
    def render_template(template_file, output_file, binding = nil)
      File.open(output_file, "w+") do |f|
        f.write(ERB.new(File.read(template_file)).result(binding))
      end
    end

    # Get yarn resolution for impac-angular
    # This will need to be extended for multiple components later
    def resolve_dependencies
      yarn_lockfile = 'yarn.lock'
      regexp = /^\s+resolved (.*impac-angular.*)$/

      File.exist?(yarn_lockfile) || raise("No lockfile found. Run install first")
      File.open(yarn_lockfile) { |file| file.find { |line| line =~ regexp } }
      Regexp.last_match(1)
    end

    # Override the frontend bower.json with the locked versions
    def override_frontend_dependencies
      resolved_version = resolve_dependencies
      unless resolved_version
        puts "No impac-angular override. Skipping"
        return
      end

      frontend_bower_file = File.join(FRONTEND_PKG_FOLDER, 'bower.json')
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

    # Equivalent of gulp injector for less files
    def less_injector(less_file, included = [], excluded = [])
      main_content = File.read(less_file)

      src_content = Dir.glob(included)
                .uniq
                .reject { |e| excluded.include?(e) }
                .map { |e| File.read(e) }

      main_content = main_content.gsub("// injector\n// endinjector", src_content.join("\n"))

      File.write(less_file, main_content)
    end

    # Build the previewer less stylesheet
    # Return the relative path of the compiled less stylesheet
    def build_theme_previewer_src_less(frontend_tmp_folder)
      # This file containers the bower (wiredep) and injector tags (see less_injector)
      src_file = "src/app/index.less"

      # The destination file is built under src so as to obtain relative
      # paths to bower_components identical to what will be expected
      # when the file is eventually copied to public/dashboard/styles
      # These relative paths are injected by wiredep (see below)
      dst_file = "src/theme-previewer.less"

      Dir.chdir(frontend_tmp_folder) do
        cp src_file, dst_file
        sh "#{WIREDEP_CMD} --src #{dst_file}"

        # Do not inject these files as they are either
        # used as template or are the destination file
        excluded = [src_file, dst_file]

        included = [
          'src/app/stylesheets/theme.less',
          'src/app/stylesheets/variables-default.less',
          'src/app/stylesheets/variables.less',
          'src/app/stylesheets/theme-previewer-published.less',
          'src/app/stylesheets/theme-previewer-tmp.less',
          'src/app/stylesheets/*.less',
          'src/app/**/*.less',
          'src/fonts/**/*.less',
          'src/images/**/*.less'
        ]

        less_injector(dst_file, included, excluded)
      end

      return dst_file
    end

    # Build the previewer css stylesheet
    # Return the relative path of the compiled css stylesheet
    def build_theme_previewer_css(frontend_tmp_folder)
      dst_file = "src/theme-previewer.css"

      src_file = build_theme_previewer_src_less(frontend_tmp_folder)

      Dir.chdir(frontend_tmp_folder) do
        sh "#{LESSC_CMD} #{src_file} #{dst_file}"
        rm_f(src_file)
      end

      return dst_file
    end

    #================================================================
    # Tasks
    #================================================================

    # TODO: refactor this
    # Task optimised for theme previewer environment (skip some steps)
    namespace :previewer do
      # Reset the frontend build folder and apply local customisations
      task :prepare_build_folder do
        # Create tmp build folder
        # Minimize copy activity if folder has already been copied
        if File.directory?("#{frontend_tmp_folder}")
          rm_rf "#{frontend_tmp_folder}/src"
          cp_r("#{FRONTEND_PKG_FOLDER}/src", "#{frontend_tmp_folder}/")
        else
          mkdir_p frontend_tmp_folder
          cp_r("#{FRONTEND_PKG_FOLDER}/.", "#{frontend_tmp_folder}/")
        end

        # Install dependencies if missing
        Dir.chdir(frontend_tmp_folder) do
          unless File.directory?("bower_components") && File.directory?("node_modules")
            sh 'yarn install'
          end
        end

        # Default variables to avoid breaking the build if there are new variables in the frontend
        mv("#{frontend_tmp_folder}/src/app/stylesheets/variables.less", "#{frontend_tmp_folder}/src/app/stylesheets/variables-default.less")

        # Apply frontend customisations
        cp_r("#{frontend_project_folder}/.", "#{frontend_tmp_folder}/")
      end

      # Rebuild the Live Previewer Style
      task :save do
        # Prepare the build folder
        Rake::Task['mnoe:frontend:previewer:prepare_build_folder'].execute

        # Build <frontend_tmp_folder>/src/theme-previewer.less
        build_theme_previewer_src_less(frontend_tmp_folder)

        # Copy stylesheets to public
        mv("#{frontend_tmp_folder}/src/theme-previewer.less", "#{frontend_dist_folder}/styles/")

        # Generates locales
        # Rake::Task['mnoe:locales:generate'].invoke

        # Clear tmp cache in development
        # if Rails.env.development? || Rails.env.test?
        #   Rake::Task['tmp:cache:clear'].execute
        # end
      end

      task :build do
        # Prepare the build folder
        Rake::Task['mnoe:frontend:previewer:prepare_build_folder'].execute

        # Create <frontend_tmp_folder>/src/theme-previewer.css
        css_file = build_theme_previewer_css(frontend_tmp_folder)

        # Compute file checksum and generate unique name
        digest = Digest::SHA1.hexdigest(File.read("#{frontend_tmp_folder}/#{css_file}"))
        css_digest_filename = "app-#{digest}.css"

        # Ensure distribution folder exists
        mkdir_p frontend_dist_folder

        # Cleanup previously compiled files
        Dir.glob("#{frontend_dist_folder}/styles/app-*.css").each do |f|
          rm_f f
        end

        # Copy new stylesheet to public
        mv("#{frontend_tmp_folder}/#{css_file}", "#{frontend_dist_folder}/styles/#{css_digest_filename}")

        # Update reference in index.html
        index_html_file = "#{frontend_dist_folder}/index.html"
        index_content = File.read(index_html_file).gsub(/styles\/app-\w+.css/, "styles/#{css_digest_filename}")
        File.write(index_html_file, index_content)

        # Generates locales
        # Rake::Task['mnoe:locales:generate'].invoke

        # Clear tmp cache in development - recompile assets otherwise
        if Rails.env.development? || Rails.env.test?
          Rake::Task['tmp:cache:clear'].execute
        else
          Rake::Task['assets:precompile'].execute
        end
      end
    end


    ## Tasks
    # TODO: replace with yarn install commands to get latest version
    desc "Yarn package file"
    file PKG_FILE do
      # Binding values for the templates
      app_name = Rails.root.basename
      mnoe_angular_pkg = "git+https://git@github.com/maestrano/mno-enterprise-angular.git##{MNOE_ANGULAR_VERSION}"
      impac_angular_pkg = "git+https://git@github.com/maestrano/impac-angular.git##{IMPAC_ANGULAR_VERSION}"

      render_template(
        File.join(File.expand_path(File.dirname(__FILE__)),'templates','package.json'),
        PKG_FILE,
        binding
      )
    end

    desc "Setup the Enterprise Express frontend"
    task :install do
      Rake::Task['mnoe:frontend:install_frontend'].invoke

      # Bootstrap frontend folder
      Rake::Task['mnoe:frontend:bootstrap_override_folder'].invoke

      # Build the frontend
      Rake::Task['mnoe:frontend:build'].invoke
      #Rake::Task['assets:precompile'].invoke
    end

    desc "Build/Rebuild the Enterprise Express frontend"
    task :build do
      # Prepare the build folder
      Rake::Task['mnoe:frontend:prepare_build_folder'].execute

      # Build frontend using Gulp
      Dir.chdir(frontend_tmp_folder) do
        sh 'yarn install'
        sh GULP_CMD
        sh "#{GULP_CMD} theme-previewer"
      end

      # Ensure distribution folder exists
      mkdir_p frontend_dist_folder

      # Cleanup previously compiled files
      Dir.glob("#{frontend_dist_folder}/{styles,scripts}/*.{css,js}").each do |f|
        rm_f f
      end

      # Copy assets to public
      cp_r("#{frontend_tmp_folder}/dist/.","#{frontend_dist_folder}/")

      # Copy bower_components to public (used by live previewer)
      cp_r("#{frontend_tmp_folder}/bower_components","#{frontend_dist_folder}/")

      # Generates locales
      Rake::Task['mnoe:locales:generate'].invoke

      # Clear tmp cache in development - recompile assets otherwise
      if Rails.env.development? || Rails.env.test?
        Rake::Task['tmp:cache:clear'].execute
      else
        Rake::Task['assets:precompile'].execute
      end
    end

    # Alias to dist for backward compatibility
    task dist: :build

    desc "Update the frontend and rebuild it"
    task update: :install_dependencies do
      # Fetch new version of the packages
      sh "yarn upgrade --ignore-scripts --ignore-engines"

      # Cleanup
      rm_rf "#{frontend_tmp_folder}/bower_components"

      # Rebuild the frontend
      Rake::Task['mnoe:frontend:build'].execute
    end

    # Install dependencies
    # TODO: DRY
    task :install_dependencies do
      unless system("which yarn")
        puts 'Yarn executable was not detected in the system.'
        puts 'Download Yarn at https://yarnpkg.com/en/docs/install'
        raise
      end

      # Install required tools
      sh("which bower || yarn global add bower")
    end

    # Create & populate the frontend override folder
    task :bootstrap_override_folder do
      # Create frontend override folder
      mkdir_p(frontend_project_folder)
      touch "#{frontend_project_folder}/.keep"

      # Bootstrap override folder
      # Replace relative image path by absolute path in the LESS files
      mkdir_p("#{frontend_project_folder}/src/app/stylesheets")
      %w(src/app/stylesheets/theme.less src/app/stylesheets/variables.less).each do |path|
        next if File.exist?("#{frontend_project_folder}/#{path}")

        # Generate file from template
        cp("#{FRONTEND_PKG_FOLDER}/#{path}","#{frontend_project_folder}/#{path}")

        # Replace image relative path
        content = File.read("#{frontend_project_folder}/#{path}")
        File.open("#{frontend_project_folder}/#{path}", 'w') do |f|
          f << content.gsub("../images", File.join(frontend_dist_folder.gsub("public",""),"images"))
        end
      end

      # Setup theme previewer working files so we can safely include
      # them in main.less
      %w(theme-previewer-tmp.less theme-previewer-published.less).each do |filename|
        FileUtils.touch(File.join(Rails.root, "frontend/src/app/stylesheets/#{filename}"))
      end

      # Create custom fonts files so we can safely include them in main.less
      frontend_font_folder = File.join(frontend_project_folder, 'src/fonts')
      unless File.exist?(File.join(frontend_font_folder, 'font-faces.less'))
        font_src = File.join(File.expand_path(File.dirname(__FILE__)), 'templates', 'font-faces.less')

        mkdir_p(frontend_font_folder)
        cp(font_src, frontend_font_folder)
      end
    end

    task install_frontend: [:install_dependencies, PKG_FILE] do
      # Fetch the packages
      sh("yarn install --ignore-scripts --ignore-engines")
    end

    # Rebuild the Live Previewer Style
    task :rebuild_previewer_style do
      # Prepare the build folder
      Rake::Task['mnoe:frontend:prepare_build_folder'].execute

      # Build the previewer stylesheet
      Dir.chdir(frontend_tmp_folder) do
        sh 'yarn install'
        sh "#{GULP_CMD} theme-previewer"
      end

      # Copy stylesheet to public
      cp("#{frontend_tmp_folder}/dist/styles/theme-previewer.less","#{frontend_dist_folder}/styles/")

      # Copy bower_components to public (used by live previewer)
      cp_r("#{frontend_tmp_folder}/bower_components","#{frontend_dist_folder}/")

      # Generates locales
      Rake::Task['mnoe:locales:generate'].invoke

      # Clear tmp cache in development
      if Rails.env.development? || Rails.env.test?
        Rake::Task['tmp:cache:clear'].execute
      end
    end

    # Reset the frontend build folder and apply local customisations
    task :prepare_build_folder do
      # Ensure frontend is downloaded
      Rake::Task['mnoe:frontend:install_frontend'].invoke unless File.directory?(FRONTEND_PKG_FOLDER)

      # Override frontend dependencies
      puts "Locking frontend dependencies"
      override_frontend_dependencies

      # Reset tmp folder from mno-enterprise-angular source
      rm_rf "#{frontend_tmp_folder}/src"
      rm_rf "#{frontend_tmp_folder}/e2e"
      mkdir_p frontend_tmp_folder
      cp_r("#{FRONTEND_PKG_FOLDER}/.", "#{frontend_tmp_folder}/")

      # Default variables to avoid breaking the build if there are new variables in the frontend
      mv("#{frontend_tmp_folder}/src/app/stylesheets/variables.less", "#{frontend_tmp_folder}/src/app/stylesheets/variables-default.less")

      # Apply frontend customisations
      cp_r("#{frontend_project_folder}/.", "#{frontend_tmp_folder}/")
    end

    desc "Remove all generated files"
    task :clean do
      clean = FileList[frontend_tmp_folder, frontend_dist_folder, FRONTEND_PKG_FOLDER, 'node_modules/.yarn-integrity']
      Rake::Cleaner.cleanup_files(clean)
    end
  end
end
