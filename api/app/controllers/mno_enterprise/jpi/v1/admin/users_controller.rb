module MnoEnterprise
  class Jpi::V1::Admin::UsersController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/@users
    def index
      @users = MnoEnterprise::User.all
    end

    # GET /mnoe/jpi/v1/admin/@users/1
    def show
      @user = MnoEnterprise::User.find(params[:id])
      @user_organizations = @user.organizations
    end
  end
end
