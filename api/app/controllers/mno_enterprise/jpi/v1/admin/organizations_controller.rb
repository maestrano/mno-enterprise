module MnoEnterprise
  class Jpi::V1::Admin::OrganizationsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/organizations
    def index
      if params[:terms]
        # Search mode
        @organizations = []
        JSON.parse(params[:terms]).map { |t| @organizations = @organizations | MnoEnterprise::Organization.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @organizations.count
      else
        # Index mode
        query = MnoEnterprise::Organization
        query = query.limit(params[:limit]) if params[:limit]
        query = query.skip(params[:offset]) if params[:offset]
        query = query.order_by(params[:order_by]) if params[:order_by]
        query = query.where(params[:where]) if params[:where]
        all = query.all

        all.params[:sub_tenant_id] = params[:sub_tenant_id]
        all.params[:account_manager_id] = params[:account_manager_id]

        @organizations = all.fetch

        response.headers['X-Total-Count'] = @organizations.metadata[:pagination][:count]
      end
    end

    # GET /mnoe/jpi/v1/admin/organizations/1
    def show
      @organization = MnoEnterprise::Organization.find(params[:id])
      @organization_active_apps = @organization.app_instances.active.to_a
    end

    # GET /mnoe/jpi/v1/admin/organizations/in_arrears
    def in_arrears
      @arrears = MnoEnterprise::ArrearsSituation.all
    end

    # GET /mnoe/jpi/v1/admin/organizations/count
    def count
      organizations_count = MnoEnterprise::Tenant.get('tenant').organizations_count
      render json: {count: organizations_count }
    end

    # POST /mnoe/jpi/v1/admin/organizations
    def create
      # Create new organization
      @organization = MnoEnterprise::Organization.create(organization_update_params)

      # OPTIMIZE: move this into a delayed job?
      update_app_list
      update_sub_tenants

      @organization_active_apps = @organization.app_instances

      render 'show'
    end

    # PATCH /mnoe/jpi/v1/admin/organizations/1
    def update
      # get organization
      @organization = MnoEnterprise::Organization.find(params[:id])

      update_app_list

      @organization_active_apps = @organization.app_instances.active

      render 'show'
    end

    # POST /mnoe/jpi/v1/admin/organizations/1/users
    # Invite a user to the organization (and create it if needed)
    # This does not send any emails (emails are manually triggered later)
    def invite_member
      @organization = MnoEnterprise::Organization.find(params[:id])

      # Find or create a new user - We create it in the frontend as MnoHub will send confirmation instructions for newly
      # created users
      user = MnoEnterprise::User.find_by(email: user_params[:email]) || create_unconfirmed_user(user_params)

      # Create the invitation
      invite = @organization.org_invites.create(
        user_email: user.email,
        user_role: params[:user][:role],
        referrer_id: current_user.id,
        status: 'staged' # Will be updated to 'accepted' for unconfirmed users
      )

      @user = user.confirmed? ? invite : user.reload
    end

    protected

    def organization_permitted_update_params
      [:name]
    end

    def organization_update_params
      params.fetch(:organization, {}).permit(*organization_permitted_update_params)
    end

    def user_params
      params.require(:user).permit(:email, :name, :surname, :phone)
    end

    # Create an unconfirmed user and skip the confirmation notification
    # TODO: monkey patch User#confirmation_required? to simplify this? Use refinements?
    def create_unconfirmed_user(user_params)
      user = MnoEnterprise::User.new(user_params)
      user.skip_confirmation_notification!
      user.save

      # Reset the confirmation field so we can track when the invite is send - #confirmation_sent_at is when the confirmation_token was generated (not sent)
      # Not ideal as we do 2 saves, and the previous save trigger a call to the backend to validate the token uniqueness
      user.assign_attributes(confirmation_sent_at: nil, confirmation_token: nil)
      user.save
      user
    end

    # Update App List to match the list passed in params
    def update_app_list
      # Differentiate between a null app_nids params and no app_nids params
      if params[:organization].key?(:app_nids) && (desired_nids = Array(params[:organization][:app_nids]))

        existing_apps = @organization.app_instances.active

        existing_apps.each do |app_instance|
          desired_nids.delete(app_instance.app.nid) || app_instance.terminate
        end

        desired_nids.each do |nid|
          begin
            @organization.app_instances.create(product: nid)
          rescue => e
            Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
          end

        end

        # Force reload
        existing_apps.reload
      end
    end

    def update_sub_tenants
      return unless params[:organization].key?(:sub_tenant_ids)

      sub_tenants = MnoEnterprise::SubTenant.where({'id.in' => params[:organization][:sub_tenant_ids]})

      sub_tenants.to_a.each do |sub_tnt|
        new_client_ids = sub_tnt.client_ids
        new_client_ids << @organization.id
        new_client_ids = new_client_ids.collect(&:to_s)

        sub_tnt.update({"client_ids"=>new_client_ids})
      end
    end
  end
end
