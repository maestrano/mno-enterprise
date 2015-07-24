module MnoEnterprise
  class Auth::RegistrationsController < Devise::RegistrationsController
    include MnoEnterprise::Concerns::Controllers::Auth::RegistrationsController 
  end
end