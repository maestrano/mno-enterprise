module MnoEnterprise::Concerns::Controllers::Auth::RegistrationsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :configure_sign_up_params, only: [:create]
    # before_filter :configure_account_update_params, only: [:update]

    protected
      def configure_sign_up_params
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(
          :email,
          :password,
          :password_confirmation,
          :name,
          :surname,
          :company,
          :phone,
          :phone_country_code,
          {metadata: [:tos_accepted_at]}
        )}
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
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    #  Filling the time at which TOS were accepted
    if params[:tos]
      params[:user][:metadata] = {tos_accepted_at: Time.current}
    end

    build_resource(sign_up_params)
    resource.password ||= Devise.friendly_token

    if resource.save

      MnoEnterprise::EventLogger.info('user_add', resource.id, 'User Signup', resource)

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        yield(:success,resource) if block_given?
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        yield(:success_but_inactive,resource) if block_given?
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      yield(:error,resource) if block_given?
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
    def after_sign_up_path_for(resource)
      mno_enterprise.user_confirmation_lounge_path
    end

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
      if !session[:previous_url].blank? && (r = session[:previous_url].match(/\/orga_invites\/(\d+)\?token=(\w+)/))
        invite_params = { id: r.captures[0].to_i, token: r.captures[1] }
        return false if MnoEnterprise::OrgaInvite.where(invite_params).any?
      end

      # Get remaining invites via email address
      return MnoEnterprise::OrgaInvite.where(user_email: user_attrs['email']).empty?
    end
end
