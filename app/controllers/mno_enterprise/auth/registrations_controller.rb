module MnoEnterprise
  class Auth::RegistrationsController < Devise::RegistrationsController
    before_filter :configure_sign_up_params, only: [:create]
    # before_filter :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    def create
      build_resource(sign_up_params)
      resource.password ||= Devise.friendly_token
      
      
      resource_saved = resource.save
      yield resource if block_given?
      
      if resource_saved
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        @validatable = devise_mapping.validatable?
        if @validatable
          @minimum_password_length = resource_class.password_length.min
        end
        respond_with resource
      end
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected
    
      # You can put the params you want to permit in the empty array.
      # def configure_account_update_params
      #   devise_parameter_sanitizer.for(:account_update) << :attribute
      # end

      # The path used after sign up.
      # def after_sign_up_path_for(resource)
      #   super(resource)
      # end

      # The path used after sign up for inactive accounts.
      # def after_inactive_sign_up_path_for(resource)
      #   super(resource)
      # end
    
      def sign_up_params
        attrs = super
        attrs.merge(orga_on_create: create_orga_on_user_creation(attrs))
      end
    
      # Check whether we should create an organization for the user
      def create_orga_on_user_creation(user_attrs)
        return false unless user_attrs['email']

        # First check previous url to see if the user
        # was trying to accept an orga
        orga_invites = []
        if !session[:previous_url].blank? && (r = session[:previous_url].match(/\/orga_invites\/(\d+)\?token=(\w+)/))
          invite_params = { id: r.captures[0].to_i, token: r.captures[1] }
          return false if MnoEnterprise::OrgInvite.where(invite_params).any?
        end

        # Get remaining invites via email address
        return MnoEnterprise::OrgInvite.where(user_email: user_attrs['email']).empty?
      end
    
      def configure_sign_up_params
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(
          :email, 
          :password, 
          :password_confirmation, 
          :name, 
          :surname,
          :company,
          :phone,
          :phone_country_code
        )} 
      end
  end
end