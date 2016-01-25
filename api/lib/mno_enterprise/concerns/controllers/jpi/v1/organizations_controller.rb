module MnoEnterprise::Concerns::Controllers::Jpi::V1::OrganizationsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/organizations
  def index
    @organizations ||= current_user.organizations
  end

  # GET /mnoe/jpi/v1/organizations/1
  def show
    organization # load organization
  end

  # PUT /mnoe/jpi/v1/organizations/:id
  def update
    # Update and Authorize
    organization.assign_attributes(organization_update_params)
    authorize! :update, organization

    # Save
    if organization.save
      render 'show_reduced'
    else
      render json: organization.errors, status: :bad_request
    end
  end

  # DELETE /mnoe/jpi/v1/organizations/1
  def destroy
    if organization
      authorize! :destroy, organization
      organization.destroy
    end

    head :no_content
  end

  # POST /mnoe/jpi/v1/organizations
  def create
    # Create new organization
    @organization = MnoEnterprise::Organization.create(organization_update_params)

    # Add the current user as Super Admin
    @organization.add_user(current_user,'Super Admin')

    render 'show'
  end

  # PUT /mnoe/jpi/v1/organizations/:id/charge
  # def charge
  #   authorize! :manage_billing, organization
  #   payment = organization.charge
  #   s = ''
  #   if payment
  #     if payment.success?
  #       s = 'success'
  #     else
  #       s = 'fail'
  #     end
  #   else
  #     s = 'error'
  #   end
  #
  #   render json: { status: s, data: payment }
  # end

  # PUT /mnoe/jpi/v1/organizations/:id/update_billing
  def update_billing
    whitelist = ['title','first_name','last_name','number','month','year','country','verification_value','billing_address','billing_city','billing_postcode', 'billing_country']
    attributes = params[:credit_card].select { |k,v| whitelist.include?(k.to_s) }
    authorize! :manage_billing, organization

    # Upsert
    if @credit_card = organization.credit_card
      @credit_card.assign_attributes(attributes.merge(organization_id: @credit_card.organization_id))
      @credit_card.save
    end

    if @credit_card.errors.empty?
      render 'credit_card'
    else
      render json: @credit_card.errors, status: :bad_request
    end
  end

  # TODO: specs
  # PUT /mnoe/jpi/v1/organizations/:id/invite_members
  def invite_members
    # Filter
    whitelist = ['email','role','team_id']
    attributes = []
    params[:invites].each do |invite|
      attributes << invite.select { |k,v| whitelist.include?(k.to_s) }
    end

    # Authorize and create
    authorize! :invite_member, organization
    attributes.each do |invite|
      @org_invite = organization.org_invites.create(
        user_email: invite['email'],
        user_role: invite['role'],
        team_id: invite['team_id'],
        referrer_id: current_user.id
      )

      MnoEnterprise::SystemNotificationMailer.organization_invite(@org_invite).deliver_now
    end

    render 'members'
  end

  # TODO: specs
  # PUT /mnoe/jpi/v1/organizations/:id/update_member
  def update_member
    attributes = params[:member]
    @member = organization.users.where(email: attributes[:email]).first
    @member ||= organization.org_invites.active.where(user_email: attributes[:email]).first

    # Authorize and update
    authorize! :invite_member, organization
    if @member.is_a?(MnoEnterprise::User)
      organization.users.update(id: @member.id, role: attributes[:role])
    elsif @member.is_a?(MnoEnterprise::OrgInvite)
      @member.user_role = attributes[:role]
      @member.save
    end

    render 'members'
  end

  # TODO: specs
  # PUT /mnoe/jpi/v1/organizations/:id/remove_member
  def remove_member
    attributes = params[:member]
    @member = organization.users.where(email: attributes[:email]).first
    @member ||= organization.org_invites.active.where(user_email: attributes[:email]).first

    # Authorize and update
    authorize! :invite_member, organization
    if @member.is_a?(MnoEnterprise::User)
      organization.remove_user(@member)
    elsif @member.is_a?(MnoEnterprise::OrgInvite)
      @member.cancel!
    end

    render 'members'
  end

  # POST /mnoe/jpi/v1/organizations/:id/app_instances_sync
  def app_instances_sync
    authorize! :sync_apps, organization

    session[:pre_sync_url] = params[:return_url] if params[:return_url]
    connectors = organization.app_instances_sync.create(mode: params[:mode]).connectors

    if !connectors.include?(false) && connectors.count > 0
      msg = "Syncing your data. This process might take a few minutes."
      # can flash be used on mnoe?
      flash[:flash_options] = {timeout: 10000}
    elsif connectors.count == 0
      msg = "No apps available for synchronization! Please either add applications to your dashboard or check they're authenticated."
    else
      msg = "We were unable to sync your data. Please retry at a later time."
    end

    render :json => { msg: msg }
  end

  # GET /mnoe/jpi/v1/organizations/:id/app_instances_sync
  def check_app_instances_sync
    authorize! :check_apps_sync, organization

    # find method is overriden in the mnoe interface to call organization.check_sync_apps_progress
    progress = organization.app_instances_sync.find('anything')
    connectors = progress.connectors
    errors = progress.errors

    # "Sync Failed" connectors are sorted to end of connectors array.
    connectors.sort_by! do |c|
      date = begin
        c[:last_sync] ? Date.parse(c[:last_sync]) : nil
      rescue ArgumentError => e
        nil
      end

      date || DateTime.new
    end
    .reverse!

    is_syncing = connectors.any? do |c|
      c[:status] ? (c[:status] == 'RUNNING') : false
    end

    last_synced = connectors.first unless is_syncing || connectors.empty?

    render :json => {
      syncing: is_syncing,
      connectors: connectors,
      last_synced: last_synced,
      errors: errors
    }
  end

  protected
    def organization
      @organization ||= current_user.organizations.to_a.find do |o|
        key = (params[:id].to_i == 0) ? o.uid : o.id.to_s
        key == params[:id].to_s
      end
    end

    def organization_permitted_update_params
      [:name, :soa_enabled, :industry, :size]
    end

    def organization_update_params
      params.fetch(:organization, {}).permit(*organization_permitted_update_params)
    end

end
