module MnoEnterprise
  class Auth::PasswordsController < Devise::PasswordsController
    include MnoEnterprise::Concerns::Controllers::Auth::PasswordsController
  end
end