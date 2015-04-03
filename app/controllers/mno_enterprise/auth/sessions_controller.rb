module MnoEnterprise
  class Auth::SessionsController < Devise::SessionsController
    prepend_before_filter :capture_return_to_redirection
    # before_filter :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    def new
      super
    end
    
    # POST /resource/sign_in
    # def create
    #   super
    # end
    # def create
    #   self.resource = warden.authenticate!(auth_options)
    #   set_flash_message(:notice, :signed_in) if is_flashing_format?
    #   sign_in(resource_name, resource)
    #   yield resource if block_given?
    #   respond_with resource, location: after_sign_in_path_for(resource)
    # end

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
end