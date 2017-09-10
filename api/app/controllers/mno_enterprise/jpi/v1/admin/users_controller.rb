module MnoEnterprise
  class Jpi::V1::Admin::UsersController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/users
    def index
      if params[:terms]
        # Search mode
        @users = []
        JSON.parse(params[:terms]).map do |t|
          @users = @users | MnoEnterprise::User.with_params(_metadata: { act_as_manager: current_user.id })
                                               .includes(:user_access_requests)
                                               .where(Hash[*t])
        end
        response.headers['X-Total-Count'] = @users.count
      else
        # Index mode
        query = MnoEnterprise::User
          .apply_query_params(params)
          .with_params(_metadata: { act_as_manager: current_user.id })
          .includes(:user_access_requests)
        @users = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/users/1
    def show
      @user = MnoEnterprise::User.with_params(_metadata: { act_as_manager: current_user.id })
                                 .includes(:orga_relations, :organizations, :user_access_requests, :clients)
                                 .find(params[:id])
                                 .first

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
      unless current_user.admin_role.in? %w(admin sub_tenant_admin)
        render :index, status: :unauthorized
        return
      end

      # Fetch user or abort if user does not exist
      # (the current_user may not have access to this record)
      @user = MnoEnterprise::User.with_params(_metadata: { act_as_manager: current_user.id }).find(params[:id]).first
      return render_not_found('User') unless @user

      # Update user
      @user.update(user_update_params)

      if @user.errors.empty?
        @user = @user.load_required(:clients)
        @user_clients = @user.clients
        render :show
      else
        render json: @user.errors.full_messages, status: :bad_request
      end
    end

    # DELETE /mnoe/jpi/v1/admin/users/1
    def destroy
      # Fetch user or abort if user does not exist
      # (the current_user may not have access to this record)
      user = MnoEnterprise::User.with_params(_metadata: { act_as_manager: current_user.id }).find(params[:id]).first

      # Destroy user
      user.destroy

      head :no_content
    end

    # GET /mnoe/jpi/v1/admin/users/count
    def count
      users_count = tenant_reporting.users_count

      render json: { count: users_count }
    end

    # GET /mnoe/jpi/v1/admin/users/kpi
    def metrics
      user_metrics = tenant_reporting.user_metrics

      render json: { metrics: user_metrics }
    end

    # POST /mnoe/jpi/v1/admin/users/signup_email
    # Send an email to a user with the link to the registration page
    def signup_email
      MnoEnterprise::SystemNotificationMailer.registration_instructions(params.require(:user).require(:email)).deliver_later

      head :no_content
    end

    private

    # Return the tenant reporting object scoped for the current user
    def tenant_reporting
      MnoEnterprise::TenantReporting
        .with_params(_metadata: { act_as_manager: current_user.id })
        .find
        .first
    end

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
