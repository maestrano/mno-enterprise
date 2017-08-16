module MnoEnterprise
  class Jpi::V1::Admin::UsersController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/users
    def index
      if params[:terms]
        # Search mode
        @users = []
        JSON.parse(params[:terms]).map { |t| @users = @users | MnoEnterprise::User.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @users.count
      else
        # Index mode
        query = MnoEnterprise::User.apply_query_params(params)
        @users = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/users/1
    def show
      @user = MnoEnterprise::User.find_one(params[:id], :orga_relations, :organizations)
      @user_organizations = @user.organizations
    end

    # POST /mnoe/jpi/v1/admin/users
    def create
      @user = MnoEnterprise::User.create(user_create_params)
      if @user.errors.empty?
        render :show
      else
        render json: @user.errors, status: :bad_request
      end
    end

    # PATCH /mnoe/jpi/v1/admin/users/:id
    def update
      # TODO: replace with authorize/ability
      if current_user.admin_role == "admin"
        @user = MnoEnterprise::User.find_one(params[:id])
        @user.update(user_params)

        render :show
      else
        render :index, status: :unauthorized
      end
    end

    # DELETE /mnoe/jpi/v1/admin/users/1
    def destroy
      user = MnoEnterprise::User.find_one(params[:id])
      user.destroy

      head :no_content
    end

    # GET /mnoe/jpi/v1/admin/users/count
    def count
      users_count = MnoEnterprise::TenantReporting.show.users_count
      render json: {count: users_count }
    end

    # GET /mnoe/jpi/v1/admin/users/kpi
    def kpi
      users_kpi = MnoEnterprise::TenantReporting.show.users_kpi
      render json: {kpi: users_kpi }
    end

    # POST /mnoe/jpi/v1/admin/users/signup_email
    # Send an email to a user with the link to the registration page
    def signup_email
      MnoEnterprise::SystemNotificationMailer.registration_instructions(params.require(:user).require(:email)).deliver_later

      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:admin_role)
    end

    def user_create_params
      attrs = [:name, :surname, :email, :phone]

      # TODO: replace with authorize/ability
      if current_user.admin_role == "admin"
        attrs << :admin_role
      end

      params.require(:user).permit(attrs).merge(
        password: Devise.friendly_token.first(12)
      )
    end
  end
end
