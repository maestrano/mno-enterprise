require 'rails/generators/base'

module MnoEnterprise
  module Generators
    class PumaStackGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("../../templates", __FILE__)
      desc "Configure a stack with Nginx + Puma + Upstart + Monit"
      
      def validate_environment
        unless available_environments.include?(environment)
          raise Exception.new("Environment '#{environment}' is not defined. Please define this environment in config/environments/#{environment}.rb")
        end
      end
      
      def install_puma_gem
        gem "puma"
        @num_cpus = ask("How many CPUs (or vCPU for EC2) does your #{environment} machine have? [1]")
        @num_cpus = "1" if @num_cpus.blank?
        template "scripts/puma.rb", "scripts/#{environment}/puma.rb"
      end
      
      def copy_setup_script
        template "scripts/setup.sh", "scripts/#{environment}/setup.sh"
      end
      
      def copy_nginx
        @app_domain = ask("What is the domain pointing to your #{environment} application? [#{default_domain}]")
        @app_domain = default_domain if @app_domain.blank?
        template "scripts/nginx/app", "scripts/#{environment}/nginx/app"
      end
      
      def copy_upstart
        template "scripts/upstart/app.conf", "scripts/#{environment}/upstart/app.conf"
        template "scripts/upstart/app-web.conf", "scripts/#{environment}/upstart/app-web.conf"
        template "scripts/upstart/app-web-server.conf", "scripts/#{environment}/upstart/app-web-server.conf"
        template "scripts/upstart/app-web-hotrestart.conf", "scripts/#{environment}/upstart/app-web-hotrestart.conf"
      end
      
      def copy_monit
        template "scripts/monit/app-server.conf", "scripts/#{environment}/monit/app-server.conf"
      end
      
      protected
        def environment
          file_name
        end
        
        def available_environments
          Dir.glob("./config/environments/*.rb").map { |filename| File.basename(filename, ".rb") }
        end
        
        def app_name
          @app_name ||= Rails.application.class.parent_name.underscore.gsub('_','-')
        end
        
        def default_domain
          @default_domain ||= "#{app_name}-mnoe.maestrano.io"
        end
    end
  end
end