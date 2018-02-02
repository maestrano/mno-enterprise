module MnoEnterprise::Concerns::Controllers::Jpi::V1::OrganizationsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
    before_filter :organization_management_enabled?, only: [:create, :update, :destroy, :update_billing,
                                                           :invite_members, :update_member, :remove_member]
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
    changes = organization.changes
    # Save
    if organization.save
      MnoEnterprise::EventLogger.info('organization_update', current_user.id, 'Organization update', organization, changes)
      render 'show_reduced'
    else
      render json: organization.errors, status: :bad_request
    end
  end

  # DELETE /mnoe/jpi/v1/organizations/1
  def destroy
    if organization
      authorize! :destroy, organization
      MnoEnterprise::EventLogger.info('organization_destroy', current_user.id, 'Organization deleted', organization)
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

    # Bust cache
    current_user.refresh_user_cache
    MnoEnterprise::EventLogger.info('organization_create', current_user.id, 'Organization created', organization)
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
    authorize! :manage_billing, organization

    # Upsert
    if (@credit_card = organization.credit_card) && check_valid_payment_method
      @credit_card.assign_attributes(organization_billing_params.merge(organization_id: @credit_card.organization_id))
      @credit_card.save
    end

    if @credit_card.errors.empty?
      render 'credit_card'
    else
      render json: @credit_card.errors, status: :bad_request
    end
  end

  # PUT /mnoe/jpi/v1/organizations/:id/invite_members
  def invite_members
    # Filter
    whitelist = ['email','role','team_id']
    attributes = []
    params[:invites].each do |invite|
      attributes << invite.slice(*whitelist)
    end

    # Authorize and create
    authorize! :invite_member, organization
    attributes.each do |invite|
      @org_invite = organization.org_invites.create(
        user_email: invite['email'],
        user_role: invite['role'],
        team_id: invite['team_id'],
        referrer_id: current_user.id,
        notification_sent_at: Time.now
      )

      MnoEnterprise::SystemNotificationMailer.organization_invite(@org_invite).deliver_now
      MnoEnterprise::EventLogger.info('user_invite', current_user.id, 'User invited', @org_invite)
    end

    # Reload users
    organization.users.reload

    render 'members'
  end

  # PUT /mnoe/jpi/v1/organizations/:id/update_member
  def update_member
    attributes = params[:member]

    # Authorize and update => Admin or Super Admin
    authorize! :invite_member, organization

    if organization.role == 'Admin'
      # Admin cannot assign Super Admin role
      raise CanCan::AccessDenied if attributes[:role] == 'Super Admin'

      # Admin cannot edit Super Admin
      raise CanCan::AccessDenied if (member.is_a?(MnoEnterprise::User) && member.role == 'Super Admin') ||
        (member.is_a?(MnoEnterprise::OrgInvite) && member.user_role == 'Super Admin')
    elsif member.id == current_user.id && attributes[:role] != 'Super Admin' && organization.users.count {|u| u.role == 'Super Admin'} <= 1
      # A super admin cannot modify his role if he's the last super admin
      raise CanCan::AccessDenied
    end

    # Happy Path
    case member
    when MnoEnterprise::User
      organization.users.update(id: member.id, role: attributes[:role])
      MnoEnterprise::EventLogger.info('user_role_update', current_user.id, 'User role update in org', organization, {email: attributes[:email], role: attributes[:role]})
    when MnoEnterprise::OrgInvite
      member.update(user_role: attributes[:role])
      MnoEnterprise::EventLogger.info('user_role_update', current_user.id, 'User role update in invitation', organization, {email: attributes[:email], role: attributes[:role]})
    end

    render 'members'
  end

  # PUT /mnoe/jpi/v1/organizations/:id/remove_member
  def remove_member
    authorize! :invite_member, organization

    if member.is_a?(MnoEnterprise::User)
      organization.remove_user(member)
      MnoEnterprise::EventLogger.info('user_role_delete', current_user.id, 'User removed from org', organization, {email: member.email})
    elsif member.is_a?(MnoEnterprise::OrgInvite)
      member.cancel!
      MnoEnterprise::EventLogger.info('user_role_delete', current_user.id, 'User removed from invitation', organization, {email: member.user_email})
    end

    render 'members'
  end

  protected
    def member
      @member ||= begin
        email = params.require(:member).require(:email)
        # Organizations are already loaded with all users
        organization.users.to_a.find { |u| u.email == email } ||
          organization.org_invites.active.where(user_email: email).first
      end
    end

    def organization
      @organization ||= begin
        # Find in arrays if organizations have been fetched
        # already. Perform remote query otherwise
        if current_user.organizations.loaded?
          current_user.organizations.to_a.find { |o| o.id.to_s == params[:id].to_s }
        else
          current_user.organizations.where(id: params[:id]).first
        end
      end
    end

    def organization_permitted_update_params
      [:name, :soa_enabled, :industry, :size]
    end

    def organization_update_params
      params.fetch(:organization, {}).permit(*organization_permitted_update_params)
    end

    def organization_billing_params
      params.require(:credit_card).permit(
        'title', 'first_name', 'last_name', 'number', 'month', 'year', 'country', 'verification_value',
        'billing_address', 'billing_city', 'billing_postcode', 'billing_country'
      )
    end

    def check_valid_payment_method
      return true unless organization.payment_restriction.present?

      if CreditCardValidations::Detector.new(organization_billing_params[:number]).valid?(*organization.payment_restriction)
        true
      else
        cards = organization.payment_restriction.map(&:capitalize).to_sentence
        @credit_card.errors.add(:number, "Payment is limited to #{cards} Card Holders")
        false
      end
    end

    def organization_management_enabled?
      return head :forbidden unless Settings.organization_management.enabled
    end
end
