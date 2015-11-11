require 'devise'
require 'devise/models/password_expirable'
require 'devise/extension_routes'

module Devise
  # Should the password expire (e.g 3.months)
  mattr_accessor :expire_password_after
  @@expire_password_after = 3.months
end

# an security extension for devise
module DeviseExtension
  module Controllers
    autoload :Helpers, 'devise/controllers/extension_helpers'
  end
end

# modules
Devise.add_module :password_expirable, controller: :password_expirable, model: 'devise/models/password_expirable', route: :password_expired

module DeviseExtension
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseExtension::Controllers::Helpers
    end
  end
end
