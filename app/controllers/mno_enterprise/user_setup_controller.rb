module MnoEnterprise
  class UserSetupController < ApplicationController
    before_filter :authenticate_user_or_signup!
    
    # GET /user_setup/:id
    # Display a specific step for the user setup
    def show
      @id = params[:id]
    end
  end
end