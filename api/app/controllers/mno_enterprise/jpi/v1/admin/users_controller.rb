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

    # PATCH /mnoe/jpi/v1/admin/users/:id
    def update
      @user = MnoEnterprise::User.find(params[:id])
      @user.update(user_params)

      render :show
    end

    # DELETE /mnoe/jpi/v1/admin/users/1
    def destroy
      user = MnoEnterprise::User.find(params[:id])
      user.destroy

      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:admin_role)
    end
  end
end
