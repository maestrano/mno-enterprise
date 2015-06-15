module MnoEnterprise
  class Auth::UnlocksController < Devise::UnlocksController
    include MnoEnterprise::Concerns::Controllers::Auth::UnlocksController
  end
end