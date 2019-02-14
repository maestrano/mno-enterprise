module MnoEnterprise::Concerns::Controllers::Auth::SessionsController
  extend ActiveSupport::Concern
  
  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    prepend_before_filter :capture_return_to_redirection
    # before_filter :configure_sign_in_params, only: [:create]
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
  # GET /resource/sign_in
  # def new
  #   super
  # end
  
  # POST /resource/sign_in
  def create
    @user = warden.authenticate!(auth_options)
    if @user.requires_otp_for_login?
      @user.activate_otp
      if @user.unconfirmed_otp_secret.present?
        @user.set_quick_response_code_in_attributes
      end
      return respond_with @user, location: after_sign_in_path_for(@user)
    end
    sign_in(@user)
    yield @user if block_given?
    respond_with @user, location: after_sign_in_path_for(@user)
  end

  def verify_otp
    user = MnoEnterprise::User.find(id: params[:user_id]).first
    if user.validate_and_consume_otp!(params[:otp_attempt])
      sign_in(user)
      respond_with user, location: after_sign_in_path_for(user)
    else
      render json: { error: 'Incorrect, please try again.' },
             status: :unauthorized
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end