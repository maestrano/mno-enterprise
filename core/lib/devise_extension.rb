require 'devise'
require 'devise/models/password_expirable'
# require 'devise/models/session_limitable'
require 'devise/extension_routes'

# Hook for impersonation
require 'devise/hooks/impersonatable'

module Devise
  # Should the password expire (e.g 3.months)
  mattr_accessor :expire_password_after
  @@expire_password_after = 3.months

  # Validate password strength
  mattr_accessor :password_regex
  @@password_regex = nil
  # Need 1 char of A-Z, a-z and 0-9
  # @@password_regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/

  mattr_accessor :password_regex_message
  @@password_regex_message = 'must contains at least one uppercase letter, one lower case letter and a number'
end

# an security extension for devise
module DeviseExtension
  module Controllers
    autoload :Helpers, 'devise/controllers/extension_helpers'
  end
end

# modules
Devise.add_module :password_expirable, controller: :password_expirable, model: 'devise/models/password_expirable', route: :password_expired
# Devise.add_module :session_limitable, model: 'devise/models/session_limitable'

ActiveSupport.on_load(:action_controller) do
  include DeviseExtension::Controllers::Helpers
end
