module MnoEnterprise
  class Auth::ConfirmationsController < Devise::ConfirmationsController
    before_filter :signed_in_and_unconfirmed, only: [:lounge,:update]
  
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
        respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
        return
      end
      
      # Case 1: user is confirmed but trying to confirm a new email address (change of email)
      # Case 2: user is a new user - in this case a form is displayed with final details to fill
      if resource.confirmed?
        resource.perform_confirmation(@confirmation_token)
        sign_in(resource)
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
        return
      end
    end
    
    # POST /resource/confirmation/finalize
    # Confirm a new user and update 
    def finalize
      @confirmation_token = params[:user].delete(:confirmation_token)
      self.resource = resource_class.find_for_confirmation(@confirmation_token)
      
      # Exit action and redirect if user is already confirmed
      if resource && resource.confirmed?
        redirect_to after_confirmation_path_for(resource_name, resource)
        return
      end
      
      if resource.errors.empty?
        resource.update_attributes(params[:user]) unless resource.confirmed?
        resource.perform_confirmation(@confirmation_token)
        resource.save
        sign_in resource
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
      end
    end
  
    # TODO: specs
    # GET /resource/confirmation/lounge
    def lounge
      self.resource = @resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    end
  
    # TODO: specs
    # PUT /resource/confirmation
    def update
      self.resource = @resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

      # Redirect straight away if no changes
      if @resource.email == params[:user][:email] 
        @resource.resend_confirmation_instructions
        redirect_to :user_confirmation_lounge
        return
      end
    
      # Update email
      previous_email = @resource.email
      @resource.email = params[:user][:email]
      @resource.skip_reconfirmation!
    
      if @resource.save
        @resource.resend_confirmation_instructions

        redirect_to mno_enterprise.user_confirmation_lounge_path, notice: "'Email updated! A confirmation email has been resent."
      else
        # Rollback
        #@resource.restore_email!

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
      def after_confirmation_path_for(resource_name, resource)
        return new_session_path(resource_name) unless signed_in?
      
        # 3 days is the duration of an invite.
        if resource.created_at > 3.days.ago
          # First auto confirm the orga invite if user has pending
          # invites
          # Get invites from previous_url (user was accepting invite but didn't have an account)
          org_invites = []
          if !session[:previous_url].blank? && (r = session[:previous_url].match(/\/org_invites\/(\d+)\?token=(\w+)/))
            invite_params = { id: r.captures[0].to_i, token: r.captures[1] }
            org_invites << MnoEnterprise::OrgInvite.where(invite_params).first
          end

          # Get remaining invites via email address
          org_invites << MnoEnterprise::OrgInvite.where(user_email: resource.email).to_a
          org_invites.flatten!
          org_invites.uniq!

          # Accept the invites
          org_invites.each do |org_invite|
            org_invite.accept!(resource) unless org_invite.expired?
          end
        end
      
        signed_in_root_path(resource)
      end
    
      # Redirects unless user is signed in and not confirmed yet
      def signed_in_and_unconfirmed
        resource = resource_class.to_adapter.get((send(:"current_#{resource_name}") || MnoEnterprise::User.new).to_key)
        return true if resource && !resource.confirmed?
      
        redirect_to mno_enterprise.myspace_path
        return false
      end
  end
end