module MnoEnterprise
  class Auth::SessionsController < Devise::SessionsController
    include MnoEnterprise::Concerns::Controllers::Auth::SessionsController

    
  end
end