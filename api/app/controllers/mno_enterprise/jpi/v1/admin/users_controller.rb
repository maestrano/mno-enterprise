module MnoEnterprise
  class Jpi::V1::Admin::UsersController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/users
    def index
      if params[:terms]
        # Search mode
        @users = []
        JSON.parse(params[:terms]).map do |t|
          @users = @users | MnoEnterprise::User
                              .apply_query_params(params.except(:terms))
                              .with_params(_metadata: act_as_manager)
                              .includes(:user_access_requests, :sub_tenant)
                              .where(Hash[*t])
        end

        # Ensure that no duplicates are returned as a result of multiple terms being applied to search query
        # ex. user.name = "John" and user.email = "john.doe@example.com" would return a duplicate when searching for "john"
        @users.uniq!{ |u| u.id }

        response.headers['X-Total-Count'] = @users.count
      else
        # Index mode
        query = MnoEnterprise::User
          .apply_query_params(params)
          .with_params(_metadata: act_as_manager)
          .includes(:user_access_requests, :sub_tenant)
        @users = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/users/1
    def show
      @user = MnoEnterprise::User.with_params(_metadata: act_as_manager)
                                 .includes(:orga_relations, :organizations, :user_access_requests, :sub_tenant)
                                 .find(params[:id])
                                 .first

      @user_organizations = @user.organizations
    end

    # POST /mnoe/jpi/v1/admin/users
    def create
      @user = MnoEnterprise::User.new(user_create_params)
      update_sub_tenant(@user)
      @user.save!
      @user = @user.load_required(:sub_tenant)
      render :show
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
      @user.attributes = user_update_params
      update_sub_tenant(@user)
      @user.save!
      @user = @user.load_required(:sub_tenant)
      render :show
    end

    # PATCH /mnoe/jpi/v1/admin/organizations/1/update_clients
    def update_clients
      @user = MnoEnterprise::User.with_params(_metadata: { act_as_manager: current_user.id }).find(params[:id]).first
      return render_not_found('User') unless @user
      attributes = params.require(:user).permit(add: [], remove: [])
      @user.update_clients!({data: {attributes: attributes}})
      @user = @user.load_required(:sub_tenant)
      render :show
    end

    # DELETE /mnoe/jpi/v1/admin/users/1
    def destroy
      # Fetch user or abort if user does not exist
      # (the current_user may not have access to this record)
      user = MnoEnterprise::User.with_params(_metadata: { act_as_manager: current_user.id }).find(params[:id]).first
      # Destroy user
      user.destroy!
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
      attrs = [:name, :surname, :email, :phone]
      # TODO: replace with authorize/ability
      if current_user.admin_role == 'admin'
        attrs << :admin_role
      end
      params.require(:user).permit(attrs)
    end

    def user_create_params
      attrs = user_update_params.merge(password: Devise.friendly_token.first(12))
      if attrs.key?(:admin_role)
        attrs.merge!(orga_on_create: true, company: 'Demo Company', demo_account: 'Staff demo company')
      end
      attrs
    end

    def update_sub_tenant(user)
      if current_user.admin_role == 'admin' && params.require(:user).has_key?(:sub_tenant_id)
        if params.require(:user)[:sub_tenant_id]
          user.relationships.sub_tenant = MnoEnterprise::SubTenant.new(id: params.require(:user)[:sub_tenant_id])
        else
          user.relationships.sub_tenant = nil
        end
      end
    end
  end
end
