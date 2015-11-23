require 'devise_extension'

Devise.setup do |config|
  # ==> Security Extension
  # Configure security extension for devise

  # Should the password expire (e.g 3.months)
  config.expire_password_after = false
end
