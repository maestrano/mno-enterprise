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
    # Filter
    whitelist = %w{name soa_enabled industry size}
    attributes = (params[:organization] || {}).slice(*whitelist)

    # Update and Authorize
    organization.assign_attributes(attributes)
    authorize! :update, organization

    # Save
    if organization.save
      render 'show_reduced'
    else
      render json: organization.errors, status: :bad_request
    end
  end

  # POST /mnoe/jpi/v1/organizations
  def create
    # Filter
    whitelist = %w{name soa_enabled industry size}
    attributes = (params[:organization] || {}).slice(*whitelist)

    # Create new organization
    @organization = MnoEnterprise::Organization.create(attributes)

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

      SystemNotificationMailer.organization_invite(@org_invite).deliver_now
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

  protected
    def organization
      @organization ||= current_user.organizations.to_a.find { |o| o.id.to_s == params[:id].to_s }
    end

end
