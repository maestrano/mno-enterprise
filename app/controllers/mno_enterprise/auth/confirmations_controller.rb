module MnoEnterprise
  class Auth::ConfirmationsController < Devise::ConfirmationsController
    include MnoEnterprise::Concerns::Controllers::Auth::ConfirmationsController
  end
end