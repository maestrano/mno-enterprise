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
        inject_into_file 'app/assets/stylesheets/application.css', after: "Rails.application.routes.draw do\n" do
          "  # MnoEnterprise Engine\n  mount MnoEnterprise::Engine => \"/mnoe\", as: :mno_enterprise"
        end
      end
      
    end
  end
end