module MnoEnterprise
  class ApplicationController < ActionController::Base
    protect_from_forgery
    include ApplicationHelper
    prepend_before_filter :skip_devise_trackable_on_xhr

    before_filter :set_default_meta
    before_filter :store_location
    before_filter :perform_return_to


    # I18n
    if MnoEnterprise.i18n_enabled
      include MnoEnterprise::Concerns::Controllers::I18n
    end

    # Angular CSRF
    if MnoEnterprise.include_angular_csrf
      include MnoEnterprise::Concerns::Controllers::AngularCSRF
    end

    #============================================
    # CanCan Authorization Rescue
    #============================================
    # Rescue the CanCan permission denied error
    rescue_from CanCan::AccessDenied do |_exception|
      respond_to do |format|
        format.html { redirect_to main_app.root_path, alert: 'Unauthorized Action' }
        format.json { render nothing: true, status: :forbidden }
      end
    end

    def current_ability
      MnoEnterprise::Ability.new(current_user)
    end

    def set_default_meta
      @meta = {}
      @meta[:title] = MnoEnterprise.app_name
      @meta[:description] = "Enterprise Applications"
    end

    #============================================
    # Devise
    #============================================
    protected

    # Do not updated devise last access timestamps on ajax call so that
    # timeout feature works properly
    # Only GET request get ignored - POST/PUT/DELETE requests reflect a
    # user action and should therefore be taken into account
    def skip_devise_trackable_on_xhr
      if request.format == 'application/json' && request.get?
        request.env["devise.skip_trackable"] = true
      end
    end

    # Return the user to the 'return_to' url if one was specified
    # previously. Only if user is signed in
    def perform_return_to
      return true unless current_user && (url = return_to_url(current_user))
      redirect_to url
    end

    # Devise will always redirect to the last non devise route
    # (alias not starting with /auth)
    # ---
    # WARNING: if one day you change the below please also check that
    # the new behaviour fits with ConfirmationsController (yes...I know...it's not clean)
    def store_location
      capture_return_to_redirection || capture_previous_url
    end

    def capture_previous_url
      if request.format == 'text/html' && request.fullpath =~ /\/(myspace|deletion_requests|org_invites|provision)/
        session[:previous_url] = request.original_url
      end
    end

    # Handle return_to parameter in URL if present
    def capture_return_to_redirection
      return false unless request.format == 'text/html' && params[:return_to].present?

      # Capture return url
      session[:return_to] = params[:return_to]
    end

    # Return the URL that the user should be immediately returned to
    def return_to_url(resource)
      return nil unless (url = session.delete(:return_to)).present?

      # Add Web Token to URL
      separator = (url =~ /\?/ ? '&' : '?')

      url + "#{separator}wtk=#{MnoEnterprise.jwt({user_id: resource.uid})}"
    end

    # Redirect to previous url and reset it
    def after_sign_in_path_for(resource)
      previous_url = session.delete(:previous_url)
      default_url = if resource.respond_to?(:admin_role) && resource.admin_role.present?
        MnoEnterprise.router.admin_path
      else
        MnoEnterprise.router.dashboard_path || main_app.root_url
      end
      return (return_to_url(resource) || previous_url || default_url)
    end

    # Some controllers needs to redirect to 'MySpace' which breaks if you dont use mnoe-frontend
    # Rather than relying on the MainApp to define dashboard_path we check it here
    # The MainApp can redefine this two methods to fit its structure
    # Some of these are extracted to individuals methods like after_provision_path.
    def mnoe_home_path
      MnoEnterprise.router.dashboard_path || main_app.root_path
    end

    def mnoe_home_url
      MnoEnterprise.router.dashboard_path || main_app.root_url
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      MnoEnterprise.router.after_sign_out_url || super
    end

    private

    # Append params to the fragment part of an existing url String
    #   add_param("/#/platform/accounts", 'foo', 'bar')
    #     => "/#/platform/accounts?foo=bar"
    #   add_param("/#/platform/dashboard/he/43?en=690", 'foo', 'bar')
    #     => "/#/platform/dashboard/he/43?en=690&foo=bar"
    def add_param_to_fragment(url, param_name, param_value)
      uri = URI(url)
      fragment = URI(uri.fragment || "")
      params = URI.decode_www_form(fragment.query || "") << [param_name, param_value]
      fragment.query = URI.encode_www_form(params)
      uri.fragment = fragment.to_s
      uri.to_s
    end
  end
end
