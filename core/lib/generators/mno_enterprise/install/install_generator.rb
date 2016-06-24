require 'rails/generators/rails/app/app_generator'

module MnoEnterprise
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      desc "Description:\n  Install Maestrano Enterprise Engine in your application\n\n"

      # class_option :skip_rspec, type: :boolean, default: false, desc: 'Skip rspec-rails installation'
      # class_option :skip_factory_girl, type: :boolean, default: false, desc: 'Skip factory_girl installation'
      class_option :skip_frontend, type: :boolean, default: false, desc: 'Skip frontend installation'
      class_option :skip_admin, type: :boolean, default: false, desc: 'Skip admin installation'

      def copy_initializer
        template "Procfile"
        template "Procfile.dev"
        template "config/initializers/mno_enterprise.rb"
        template "config/mno_enterprise_styleguide.yml"

        # Settings
        template "config/settings.yml", "config/settings.yml"
        create_file "config/settings.local.yml"
        directory "config/settings", "config/settings"

        template "config/application.yml", "config/application.yml"
        template "config/application.yml", "config/application.sample.yml"
      end

      def setup_assets
        if defined?(MnoEnterprise::Frontend)
          # Stylesheets
          copy_file "stylesheets/main.less", "app/assets/stylesheets/main.less", skip: true

          # Require main stylesheet file
          inject_into_file 'app/assets/stylesheets/application.css', before: " */" do
            " *= require main\n"
          end

          # Disable require_tree which breaks the app
          gsub_file 'app/assets/stylesheets/application.css', /\*= require_tree ./, '* require_tree .'
        end
      end

      def setup_less_development_paths
        if defined?(MnoEnterprise::Frontend) || Rails.env.test?
          application(nil, env: "development") do
            "# Reload frontend stylesheets on changes\n  config.less.paths << \"\#{Rails.root}/frontend/src/app/stylesheets\"\n"
          end
        end
      end

      def update_gitignore
        create_file '.gitignore' unless File.exists? '.gitignore'

        append_to_file '.gitignore' do
          "\n"                                +
          "# Ignore application configuration\n" +
          "config/application.yml\n"          +
          "config/application-*.yml\n"        +
          "config/settings.local.yml\n"       +
          "config/settings/*.local.yml\n"     +
          "config/environments/*.local.yml\n" +
          "\n"                                +
          "# Bower and Node packages\n"       +
          "bower_components\n"                +
          "node_modules\n"
        end
      end

      def setup_frontend
        unless options[:skip_frontend]
          say("\n")
          @install_frontend = ask_with_default("Would you like to install Maestrano Enterprise Angular (frontend)?")
          if @install_frontend
            rake "mnoe:frontend:install"
          end
        end
      end

      def setup_admin
        unless options[:skip_admin]
          say("\n")
          @install_admin = ask_with_default("Would you like to install Maestrano Enterprise Admin Dashboard (frontend)?")
          if @install_admin
            rake "mnoe:admin:install"
          end
        end
      end

      # Inject engine routes
      def notify_about_routes
        if (routes_file = destination_path.join('config', 'routes.rb')).file? && (routes_file.read !~ %r{mount\ MnoEnterprise::Engine})
          mount = %Q{  # This line mount Maestrano Enterprise routes in your application under /mnoe.
  # If you would like to change where this engine is mounted, simply change the :at option to something different
  #
  # We ask that you don't use the :as option here, as Mnoe relies on it being the default of "mno_enterprise"
  scope '(:locale)' do
    mount MnoEnterprise::Engine, at: '/mnoe', as: :mno_enterprise
  end

  root to: redirect('mnoe/auth/users/sign_in')
}
          inject_into_file routes_file, mount, after: "Rails.application.routes.draw do\n"
        end

        unless options[:quiet]
          say "\n"
          say "We added the following line to your application's config/routes.rb file:"
          say "    mount MnoEnterprise::Engine, at: '/mnoe'"
          say "    root to: redirect(MnoEnterprise.router.dashboard_path)"
        end
      end

      def install_summary
        unless options[:quiet]
          say("\n\n")
          say_status("==> Maestrano Enterprise has been installed ==", nil)
          say("- You can generate deployment configs by running: 'rails g mno_enterprise:puma_stack'")
          say("- You can start the server with: 'foreman start'")

          if @install_frontend
            say("\n\n")
            say_status("==> Maestrano Enterprise Angular has been installed", nil)
            say("- You can quickly customize the platform style in frontend/src/app/stylesheets")
            say("- You can customize the whole frontend by overriding mno-enterprise-angular in frontend/src/")
            say("- You can run 'rake mnoe:frontend:dist' to rebuild the frontend after changing frontend/src")
          end

          if @install_admin
            say("\n\n")
            say_status("==> Maestrano Enterprise Admin Dashboard has been installed", nil)
            say("- You can access the platform with an admin user (admin_role = 'admin')")
          end

          say("\n\n")
        end
      end

      private
        # Helper method to quickly convert destination_root to a Pathname for easy file path manipulation
        def destination_path
          @destination_path ||= Pathname.new(self.destination_root)
        end

        # Ask a question with a default answer
        # Returns a boolean
        def ask_with_default(message, default = 'yes', color = nil)
          question = "#{message} (yes/no) [#{default}]"

          valid = false
          until valid
            answer = ask(question)
            answer = default if answer.empty?
            valid = (answer  =~ /\Ay(?:es)?|no?\Z/i)
          end
          answer.downcase[0] == ?y
        end
    end
  end
end
