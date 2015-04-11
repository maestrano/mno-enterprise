require 'rails/generators/base'

module MnoEnterprise
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Install Maestrano Enterprise Engine in your application"
      
      def copy_initializer
        template "initializers/mno_enterprise.rb", "config/initializers/mno_enterprise.rb"
        template "stylesheets/main.less", "app/assets/stylesheets/main.less"
        template "stylesheets/variables.less", "app/assets/stylesheets/variables.less"
        
        # Require main stylesheet file
        inject_into_file 'app/assets/stylesheets/application.css', before: " */" do
          " *= require main\n"
        end
        
        # Inject engine routes
        inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do
          "  # MnoEnterprise Engine\n  mount MnoEnterprise::Engine => \"/mnoe\", as: :mno_enterprise\n\n"
        end
      end
      
      def install_sprite_generator
        default_answer = 'y'
        @install_sprite = ask("Do you want to install sprite-factory? [Yn]")
        @install_sprite = default_answer if @install_sprite.blank?
        if @install_sprite =~ /y/i
          gem "chunky_png", group: :development
          gem "sprite-factory", group: :development
          template "tasks/sprites.rake", "lib/tasks/sprites.rake"
        end
      end
      
      def install_rspec_rails
        default_answer = 'y'
        @install_rspec = ask("Do you want to install rspec-rails? [Yn]")
        @install_rspec = default_answer if @install_rspec.blank?
        if @install_rspec =~ /y/i
          gem "rspec-rails", group: :test
          generate "rspec:install"
        end
      end
      
      def install_rspec_rails
        default_answer = 'y'
        @install_facto_girl = ask("Do you want to install factory_girl_rails? [Yn]")
        @install_facto_girl = default_answer if @install_facto_girl.blank?
        if @install_facto_girl =~ /y/i
          gem "factory_girl_rails", group: :test
        end
      end
      
      def install_summary
        say("\n\n")
        say("==> Maestrano Enterprise has been installed ==")
        say("- You can generate deployment configs by running: 'rails g mno_enterprise:puma_stack'")
        if @install_sprite =~ /y/i
          say("\n\n")
          say("==> Sprite Factory has been installed")
          say("- Drop your icons in vendor/sprites/icons then run: 'rake assets:resprite'")
          say("- Add more icons folders to vendor/sprites then modify lib/tasks/sprites.rake")
        end
        say("\n\n")
      end
    end
  end
end