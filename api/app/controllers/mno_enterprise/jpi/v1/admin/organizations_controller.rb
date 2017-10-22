module MnoEnterprise
  class Jpi::V1::Admin::OrganizationsController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user']
    INCLUDED_FIELDS = [:uid, :name, :account_frozen,
                       :soa_enabled, :mails, :logo, :latitude, :longitude,
                       :geo_country_code, :geo_state_code, :geo_city,
                       :geo_tz, :geo_currency, :metadata, :industry, :size,
                       :financial_year_end_month, :credit_card,
                       :financial_metrics, :created_at]
    # GET /mnoe/jpi/v1/admin/organizations
    def index
      if params[:terms]
        # Search mode
        @organizations = []
        JSON.parse(params[:terms]).map do |t|
          @organizations = @organizations | MnoEnterprise::Organization.with_params(_metadata: { act_as_manager: current_user.id })
                                              .select(INCLUDED_FIELDS)
                                              .where(Hash[*t])
        end
        response.headers['X-Total-Count'] = @organizations.count
      else
        # Index mode
        # Explicitly list fields to be retrieved to trigger financial_metrics calculation
        query = MnoEnterprise::Organization
                  .apply_query_params(params)
                  .with_params(_metadata: { act_as_manager: current_user.id })
                  .select(INCLUDED_FIELDS)

        @organizations = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/organizations/1
    def show
      @organization = MnoEnterprise::Organization.apply_query_params(params)
                        .with_params(_metadata: { act_as_manager: current_user.id })
                        .includes(*DEPENDENCIES)
                        .find(params[:id])
                        .first

      @organization_active_apps = @organization.app_instances.select(&:active?)
    end

    # TODO: sub-tenant scoping
    #
    # GET /mnoe/jpi/v1/admin/organizations/in_arrears
    def in_arrears
      @arrears = MnoEnterprise::ArrearsSituation.all
    end

    # GET /mnoe/jpi/v1/admin/organizations/count
    def count
      organizations_count = MnoEnterprise::TenantReporting.with_params(_metadata: { act_as_manager: current_user.id })
                              .find
                              .first
                              .organizations_count
      render json: { count: organizations_count }
    end

    # POST /mnoe/jpi/v1/admin/organizations
    def create
      # Create new organization
      @organization = MnoEnterprise::Organization.create(organization_update_params)
      @organization = @organization.load_required(*DEPENDENCIES)
      # OPTIMIZE: move this into a delayed job?
      update_app_list
      @organization = @organization.load_required(*DEPENDENCIES)
      @organization_active_apps = @organization.app_instances

      render 'show'
    end

    # PATCH /mnoe/jpi/v1/admin/organizations/1
    def update
      # get organization
      @organization = MnoEnterprise::Organization.with_params(_metadata: { act_as_manager: current_user.id })
                        .includes(*DEPENDENCIES)
                        .find(params[:id])
                        .first
      return render_not_found('Organization') unless @organization

      # Update organization
      @organization.update(organization_update_params)

      update_app_list
      @organization = @organization.load_required(*DEPENDENCIES)
      @organization_active_apps = @organization.app_instances.select(&:active?)

      render 'show'
    end

    # POST /mnoe/jpi/v1/admin/organizations/1/users
    # Invite a user to the organization (and create it if needed)
    # This does not send any emails (emails are manually triggered later)
    def invite_member
      @organization = MnoEnterprise::Organization.with_params(_metadata: { act_as_manager: current_user.id })
                        .includes(:orga_relations)
                        .find(params[:id])
                        .first
      return render_not_found('Organization') unless @organization

      # Find or create a new user - We create it in the frontend as MnoHub will send confirmation instructions for newly
      # created users
      user = MnoEnterprise::User.includes(:orga_relations).where(email: user_params[:email]).first || create_unconfirmed_user(user_params)

      # Create the invitation
      invite = MnoEnterprise::OrgaInvite.create(
        organization_id: @organization.id,
        user_email: user.email,
        user_role: params[:user][:role],
        referrer_id: current_user.id,
        status: 'staged' # Will be updated to 'accepted' for unconfirmed users
      )
      invite = invite.load_required(:user)
      @user = user.confirmed? ? invite : user
    end

    # PUT /mnoe/jpi/v1/admin/organizations/1/freeze
    def freeze
      @organization = MnoEnterprise::Organization.with_params(_metadata: { act_as_manager: current_user.id })
                                                 .includes(*DEPENDENCIES)
                                                 .find(params[:id])
                                                 .first
      return render_not_found('Organization') unless @organization

      last_result_set = @organization.freeze
      updated = last_result_set.first
      @organization.attributes = updated.attributes

      render 'show'
    end

    # PUT /mnoe/jpi/v1/admin/organizations/1/unfreeze
    def unfreeze
      @organization = MnoEnterprise::Organization.with_params(_metadata: { act_as_manager: current_user.id })
                                                 .includes(*DEPENDENCIES)
                                                 .find(params[:id])
                                                 .first
      return render_not_found('Organization') unless @organization

      last_result_set = @organization.unfreeze
      updated = last_result_set.first
      @organization.attributes = updated.attributes

      render 'show'
    end

    def download_batch_example
      path = File.join(File.dirname(File.expand_path(__FILE__)), '../../../../../assets/batch-example.csv')
      send_file(path, filename: 'batch-example.csv', type: 'application/csv')
    end

    # POST /mnoe/jpi/v1/admin/organization/batch_import
    def batch_import
      file = params[:file]
      # get the file's temporary path
      path = file.tempfile.path
      @import_report = MnoEnterprise::CSVImporter.process(path)
      render 'batch_import'
    rescue MnoEnterprise::CSVImportError => e
      render json: e.errors, status: :bad_request
    end

    protected
    def organization_permitted_update_params
      [:name, :billing_currency]
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
      user.password = Devise.friendly_token
      user.save!

      # Reset the confirmation field so we can track when the invite is send - #confirmation_sent_at is when the confirmation_token was generated (not sent)
      # Not ideal as we do 2 saves, and the previous save trigger a call to the backend to validate the token uniqueness
      # TODO: See if we can tell Devise to not set the timestamps
      user.attributes = { confirmation_sent_at: nil, confirmation_token: nil }
      user.save!
      user.load_required(:orga_relations)
    end

    # Update App List to match the list passed in params
    def update_app_list
      # Differentiate between a null app_nids params and no app_nids params
      if params[:organization].key?(:app_nids) && (desired_nids = Array(params[:organization][:app_nids]))
        existing_apps = @organization.app_instances&.select(&:active?) || []
        existing_apps.each { |app_instance| desired_nids.delete(app_instance.app.nid) || app_instance.terminate }
        desired_nids.each { |nid| @organization.provision_app_instance(nid) }
      end
    end
  end
end

