# This module allow Angular to works well with Rails CSRF protection
# It's intended for AngularJS app served outside of the Rails asset pipeline.
# See
#   - https://technpol.wordpress.com/2014/04/17/rails4-angularjs-csrf-and-devise/
#   - https://technpol.wordpress.com/2014/08/22/10-adding-devise-integration-logon-and-security/
# for more details
module MnoEnterprise::Concerns::Controllers::AngularCSRF
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    # Prevent CSRF attacks by raising an exception.
    protect_from_forgery with: :exception

    after_filter :set_csrf_cookie_for_ng

    # Clean up cookies on InvalidAuthenticityRequest
    rescue_from ActionController::InvalidAuthenticityToken do |exception|
      cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
      message = 'CSRF token error, please try again'
      render_with_protection(message.to_json, {status: :unprocessable_entity})
    end

    protected
    def set_csrf_cookie_for_ng
      cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
    end

    def verified_request?
      super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

    # JSON / JSONP XSS protection
    def render_with_protection(object, parameters = {})
      render parameters.merge(content_type: 'application/json', text: ")]}',\n" + object.to_json)
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
  # GET /resource/password/new
  # def new
  #   super
  # end
end
