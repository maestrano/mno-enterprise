require 'rails/generators/rails/app/app_generator'

module MnoEnterprise
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      desc "Description:\n  Install Maestrano Enterprise Engine in your application\n\n"

      class_option :skip_rspec, type: :boolean, default: false, desc: 'Skip rspec-rails installation'
      class_option :skip_sprite, type: :boolean, default: false, desc: 'Skip sprite-factory installation'
      class_option :skip_factory_girl, type: :boolean, default: false, desc: 'Skip sprite-factory installation'



      def copy_initializer
        template "Procfile"
        template "config/initializers/mno_enterprise.rb"
        template "config/mno_enterprise_styleguide.yml"
      end

      def setup_assets
        if defined?(MnoEnterprise::Frontend) || Rails.env.test?
          # JavaScript
          copy_file "javascripts/mno_enterprise_extensions.js", "app/assets/javascripts/mno_enterprise_extensions.js"

          # Stylesheets
          copy_file "stylesheets/main.less", "app/assets/stylesheets/main.less"
          #copy_file "stylesheets/theme.less_erb", "app/assets/stylesheets/theme.less.erb"
          #copy_file "stylesheets/variables.less", "app/assets/stylesheets/variables.less"

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
        append_file '.gitignore' do
          "\n# Bower and Node packages\nbower_components\nnode_modules"
        end
      end

      def setup_frontend
        rake "mnoe:frontend:install"
      end

      # Inject engine routes
      def notify_about_routes
        if (routes_file = destination_path.join('config', 'routes.rb')).file? && (routes_file.read !~ %r{mount\ MnoEnterprise::Engine})
          mount = %Q{
  # This line mount Maestrano Enterprise routes in your application under /mnoe.
  # If you would like to change where this engine is mounted, simply change the :at option to something different
  #
  # We ask that you don't use the :as option here, as Mnoe relies on it being the default of "mno_enterprise"
  mount MnoEnterprise::Engine, at: '/mnoe', as: :mno_enterprise

}
          inject_into_file routes_file, mount, after: "Rails.application.routes.draw do\n"
        end

        unless options[:quiet]
          say " "
          say "We added the following line to your application's config/routes.rb file:"
          say " "
          say "    mount MnoEnterprise::Engine, at: '/mnoe'"
        end
      end

      def install_sprite_generator
        if (defined?(MnoEnterprise::Frontend) || Rails.env.test?) && !options[:skip_sprite]
          say("\n")
          @install_sprite = ask_with_default('Would you like to install sprite-factory?')
          if @install_sprite
            gem_group :development do
              gem "chunky_png"
              gem "sprite-factory"
            end
            template "tasks/sprites.rake", "lib/tasks/sprites.rake"
          end
        end
      end

      def install_rspec_rails
        unless options[:skip_rspec]
          say("\n")
          @install_rspec = ask_with_default("Would you like to install rspec-rails?")
          if @install_rspec
            gem_group :test do
              gem "rspec-rails"
            end
            generate "rspec:install"
          end
        end
      end

      def install_factory_girl
        unless options[:skip_factory_girl]
          say("\n")
          @install_facto_girl = ask_with_default("Would you like to install factory_girl_rails?")
          if @install_facto_girl
            gem_group :test do
              gem "factory_girl_rails"
            end
          end
        end
      end

      def install_summary
        unless options[:quiet]
          say("\n\n")
          say_status("==> Maestrano Enterprise has been installed ==", nil)
          say("- You can generate deployment configs by running: 'rails g mno_enterprise:puma_stack'")
          say("- You can start the server with: 'foreman start'")

          say("\n\n")
          say_status("==> Maestrano Enterprise Angular has been installed", nil)
          say("- You can quickly customize the platform style in frontend/src/app/stylesheets")
          say("- You can customize the whole frontend by overriding mno-enterprise-angular in frontend/src/")
          say("- You can run 'rake mnoe:frontend:dist' to rebuild the frontend after changing frontend/src")

          if @install_sprite
            say("\n\n")
            say_status("==> Sprite Factory has been installed", nil)
            say("- Drop your icons in vendor/sprites/icons then run: 'rake assets:resprite'")
            say("- Add more icons folders to vendor/sprites then modify lib/tasks/sprites.rake")
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
