require 'rails/generators/base'

module MnoEnterprise
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Create a Maestrano Enterprise initializer"
      
      def copy_initializer
        template "mno_enterprise.rb", "config/initializers/mno_enterprise.rb"
      end
    end
  end
end