module MnoEnterprise
  class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include MnoEnterprise::Concerns::Controllers::Auth::OmniauthCallbacksController
  end
end

