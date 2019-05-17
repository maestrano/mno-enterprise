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
    self.resource = warden.authenticate!(auth_options)
    if resource.requires_otp_for_login?
      resource.activate_otp
      resource.set_quick_response_code_in_attributes if resource.unconfirmed_otp_secret.present?
      sign_out(resource)
    else
      sign_in(resource)
    end
    yield resource if block_given?
    respond_with(resource, location: after_sign_in_path_for(resource))
  end

  # POST /resource/sessions/verify_otp
  def verify_otp
    self.resource = MnoEnterprise::User.find(id: params[:user_id])&.first
    if resource.validate_and_consume_otp!(params[:otp_attempt])
      sign_in(resource)
      yield resource if block_given?
      respond_with(resource, location: after_sign_in_path_for(resource))
    else
      render(json: { error: 'Incorrect, please try again.' }, status: :unauthorized)
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