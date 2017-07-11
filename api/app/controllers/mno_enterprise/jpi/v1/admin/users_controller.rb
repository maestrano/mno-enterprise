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
        query = MnoEnterprise::User
        query = query.limit(params[:limit]) if params[:limit]
        query = query.skip(params[:offset]) if params[:offset]
        query = query.order_by(params[:order_by]) if params[:order_by]
        query = query.where(params[:where]) if params[:where]

        all = query.all
        all.params[:sub_tenant_id] = current_user.mnoe_sub_tenant_id
        all.params[:account_manager_id] = current_user.id
        @users = all.fetch

        response.headers['X-Total-Count'] = @users.metadata[:pagination][:count]
      end
    end

    # GET /mnoe/jpi/v1/admin/users/1
    def show
      @user = MnoEnterprise::User.find(params[:id])
      @user_organizations = @user.organizations
      @user_clients = @user.clients
    end

    # POST /mnoe/jpi/v1/admin/users
    def create
      @user = MnoEnterprise::User.build(user_create_params)

      if @user.save
        render :show
      else
        render json: @user.errors, status: :bad_request
      end
    end

    # PATCH /mnoe/jpi/v1/admin/users/:id
    def update
      # TODO: replace with authorize/ability
      if current_user.admin_role == "admin"
        @user = MnoEnterprise::User.find(params[:id])
        @user.update(user_params)
        @user_clients = @user.clients
        render :show
      else
        render :index, status: :unauthorized
      end
    end

    # DELETE /mnoe/jpi/v1/admin/users/1
    def destroy
      user = MnoEnterprise::User.find(params[:id])
      user.destroy

      head :no_content
    end

    # GET /mnoe/jpi/v1/admin/users/count
    def count
      users_count = MnoEnterprise::Tenant.get('tenant').users_count
      render json: {count: users_count }
    end

    # POST /mnoe/jpi/v1/admin/users/signup_email
    # Send an email to a user with the link to the registration page
    def signup_email
      MnoEnterprise::SystemNotificationMailer.registration_instructions(params.require(:user).require(:email)).deliver_later

      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:name, :surname, :admin_role, :mnoe_sub_tenant_id, :client_ids => [])
    end

    def user_create_params
      attrs = [:name, :surname, :email, :phone, :mnoe_sub_tenant_id, client_ids: []]
      # TODO: replace with authorize/ability
      if current_user.admin_role == 'admin'
        attrs << :admin_role
      end
      params.require(:user).permit(attrs).merge(
        password: Devise.friendly_token.first(12)
      )
    end
  end
end
