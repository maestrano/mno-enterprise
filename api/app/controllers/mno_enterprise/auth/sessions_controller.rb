module MnoEnterprise
  class Auth::SessionsController < Devise::SessionsController
    include MnoEnterprise::Concerns::Controllers::Auth::SessionsController

    # TODO: warning: not to be merged, temp workaround
    skip_before_filter :verify_authenticity_token
  end
end
