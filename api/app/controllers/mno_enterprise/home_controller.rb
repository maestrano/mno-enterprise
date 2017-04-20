module MnoEnterprise
  class HomeController < ApplicationController
    before_filter :authenticate_user!

    def index
      redirect_to user_default_url(current_user)
    end
  end
end
