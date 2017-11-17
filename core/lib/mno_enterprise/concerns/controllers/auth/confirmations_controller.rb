module MnoEnterprise::Concerns::Controllers::Auth::ConfirmationsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :signed_in_and_unconfirmed, only: [:lounge,:update]

    private
      # Redirects unless user is signed in and not confirmed yet
      def signed_in_and_unconfirmed
        resource = resource_class.to_adapter.get((send(:"current_#{resource_name}") || MnoEnterprise::User.new).to_key)
        return true if resource && !resource.confirmed?

        redirect_to MnoEnterprise.router.dashboard_path
        return false
      end
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # Override to display a form for the user to fill the final registration details
  def show
    @confirmation_token = params[:confirmation_token]
    self.resource = resource_class.find_for_confirmation(@confirmation_token)

    # Exit if no resources
    unless resource.errors.empty?
      yield(:error, resource) if block_given?
      respond_with resource.errors, status: :unprocessable_entity
      return
    end

    # Case 1: user is confirmed but trying to confirm a new email address (change of email)
    # Case 2: user is a new user - in this case a form is displayed with final details to fill
    # Case 3: user is confirmed and clicking again on the link
    if resource.confirmed?
      resource.perform_confirmation(@confirmation_token)

      if resource.errors.empty?
        sign_in(resource)
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        yield(:reconfirmation_success, resource) if block_given?
        resource.attributes['new_email_confirmed'] = true
        resource.refresh_user_cache
        respond_with resource
      else
        respond_with resource
      end
      return
    end

    # Check if phone number should be required
    # Bypassed for invited users
    resource_with_organizations = resource.load_required(:organizations, :'organizations.orga_relations')
    @phone_required = resource_with_organizations.organizations.map(&:orga_relations).flatten.count == 1
    yield(:success, resource) if block_given?
    resource_with_organizations.attributes['no_phone_required'] = true
    respond_with resource_with_organizations
  end

  # PATCH /resource/confirmation/finalize
  # Confirm a new user and update
  def finalize
    @confirmation_token = params[:user].delete(:confirmation_token)
    self.resource = resource_class.find_for_confirmation(@confirmation_token)

    # Exit action and redirect if user is already confirmed
    if resource && resource.confirmed?
      yield(:already_confirmed, resource) if block_given?
      redirect_to after_confirmation_path_for(resource_name, resource)
      return
    end

    if resource.errors.empty?
      if params[:tos] == "accept"
        params[:user][:metadata] = resource.metadata.merge(tos_accepted_at: Time.current)
      end
      resource.attributes = params[:user] unless resource.confirmed?
      resource.perform_confirmation(@confirmation_token)
      resource.save
      sign_in resource, bypass: true
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      yield(:success,resource) if block_given?
      MnoEnterprise::EventLogger.info('user_confirm', resource.id, 'User confirmed', resource)
      respond_with resource
    else
      yield(:error,resource) if block_given?
      respond_with resource.errors, status: :unprocessable_entity
    end
  end

  # TODO: specs
  # GET /resource/confirmation/lounge
  def lounge
    self.resource = @resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    yield(:success,resource) if block_given?
  end

  # TODO: specs
  # PUT /resource/confirmation
  def update
    self.resource = @resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    # Redirect straight away if no changes
    if @resource.email == params[:user][:email]
      @resource.resend_confirmation_instructions
      redirect_to mno_enterprise.user_confirmation_lounge_path, notice: "The confirmation email has been resent."
      return
    end

    # Update email
    previous_email = @resource.email
    @resource.email = params[:user][:email]
    @resource.skip_reconfirmation!

    if @resource.save
      @resource.resend_confirmation_instructions
      yield(:success,resource) if block_given?
      redirect_to mno_enterprise.user_confirmation_lounge_path, notice: "'Email updated! A confirmation email has been resent."
    else
      # Rollback
      #@resource.restore_email!
      yield(resource,:error) if block_given?
      render 'lounge'
    end
  end

  protected
    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    # The path used after confirmation.
    # Confirm any outstanding organization invite
    # TODO: invite acceptance logic should be moved to the 'show' action
    def after_confirmation_path_for(resource_name, resource, opts = {})
      return new_user_session_path unless resource

      # 3 days is the duration of an invite.
      if resource.created_at > 3.days.ago
        # First auto confirm the orga invite if user has pending
        # invites
        # Get invites from previous_url (user was accepting invite but didn't have an account)
        org_invites = []
        if !session[:previous_url].blank? && (r = session[:previous_url].match(/\/org_invites\/(\d+)\?token=(\w+)/))
          invite_params = { id: r.captures[0].to_i, token: r.captures[1] }
          org_invites << MnoEnterprise::OrgaInvite.where(invite_params).first
        end

        # Get remaining invites via email address
        org_invites << MnoEnterprise::OrgaInvite.where(user_email: resource.email).to_a
        org_invites.flatten!
        org_invites.uniq!

        # Accept the invites
        org_invites.each do |org_invite|
          org_invite.accept!(resource) unless org_invite.expired?
        end
      end

      new_user_signed_in_session_path(resource, opts)
    end

    def new_user_signed_in_session_path(resource, opts)
      if MnoEnterprise.style.workflow.signup_onboarding && opts[:new_user]
        warn '[DEPRECATION] Onboarding workflow is deprecated.'
        after_sign_in_path_for(resource)
      elsif opts[:new_user]
        after_sign_in_path_for(resource)
      else
        signed_in_root_path(resource)
      end
    end
end
