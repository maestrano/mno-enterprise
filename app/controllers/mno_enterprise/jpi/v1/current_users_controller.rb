module MnoEnterprise
  class Jpi::V1::CurrentUsersController < ApplicationController
    before_filter :authenticate_user!, only: [:update]
    respond_to :json

    # GET /mnoe/jpi/v1/current_user
    def show
      @user = current_user || User.new
    end
    
    # PUT /mnoe/jpi/v1/current_user
    def update
      @user = current_user
      
      if @user.update(user_params)
        render 'show'
      else
        render json: resource.errors, status: :bad_request
      end
    end
    
    private
      def user_params
        params.require(:user).permit(:name, :surname, :email, :company, :workspace, :settings, :reseller_code, :phone, :website, :phone_country_code)
      end
  end
end
