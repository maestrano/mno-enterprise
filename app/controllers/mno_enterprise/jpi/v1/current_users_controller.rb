module MnoEnterprise
  class Jpi::V1::CurrentUsersController < ApplicationController
    respond_to :json

    # GET /mnoe/jpi/v1/current_user
    def show
      @user = current_user || User.new
    end
  end
end
