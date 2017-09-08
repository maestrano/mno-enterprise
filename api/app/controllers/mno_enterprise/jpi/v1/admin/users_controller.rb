module MnoEnterprise
  class Jpi::V1::Admin::UsersController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/users
    def index
      if params[:terms]
        # Search mode
        @users = []
        JSON.parse(params[:terms]).map { |t| @users = @users | MnoEnterprise::User.includes(:user_access_requests).where(Hash[*t]) }
        response.headers['X-Total-Count'] = @users.count
      else
        # Index mode
        query = MnoEnterprise::User.apply_query_params(params).includes(:user_access_requests)
        query = query.where(sub_tenant_id: params[:sub_tenant_id]) if params[:sub_tenant_id]
        query = query.where(account_manager_id: params[:account_manager_id]) if params[:account_manager_id]
        @users = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/users/1
    def show
      @user = MnoEnterprise::User.find_one(params[:id], :orga_relations, :organizations, :user_access_requests, :clients)
      @user_organizations = @user.organizations
      @user_clients = @user.clients
    end

    # POST /mnoe/jpi/v1/admin/users
    def create
      @user = MnoEnterprise::User.create(user_create_params)
      if @user.errors.empty?
        @user = @user.load_required(:clients)
        render :show
      else
        render json: @user.errors.full_messages, status: :bad_request
      end
    end

    # PATCH /mnoe/jpi/v1/admin/users/:id
    def update
      # TODO: replace with authorize/ability
      if current_user.admin_role.in? %w(admin sub_tenant_admin)
        @user = MnoEnterprise::User.find_one(params[:id])
        @user.update(user_update_params)
        if @user.errors.empty?
          @user = @user.load_required(:clients)
          render :show
        else
          render json: @user.errors.full_messages, status: :bad_request
        end
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
    def metrics
      user_metrics = MnoEnterprise::TenantReporting.show.user_metrics
      render json: {metrics: user_metrics }
    end

    # POST /mnoe/jpi/v1/admin/users/signup_email
    # Send an email to a user with the link to the registration page
    def signup_email
      MnoEnterprise::SystemNotificationMailer.registration_instructions(params.require(:user).require(:email)).deliver_later

      head :no_content
    end

    private

    def user_update_params
      attrs = [:name, :surname, :email, :phone, client_ids: []]
      # TODO: replace with authorize/ability
      if current_user.admin_role == 'admin'
        attrs << :admin_role
        attrs << :mnoe_sub_tenant_id
      end
      user_param = params.require(:user)
      updated_params = user_param.permit(attrs)
      updated_params[:sub_tenant_id] = updated_params.delete(:mnoe_sub_tenant_id)
      updated_params[:client_ids] ||= [] if user_param.has_key?(:client_ids)
      # if the user is updated to admin or division admin, his clients are cleared
      if updated_params[:admin_role] && updated_params[:admin_role] != 'staff'
        updated_params[:client_ids] = []
      end
      updated_params
    end

    def user_create_params
      user_update_params.merge(password: Devise.friendly_token.first(12))
    end
  end
end
