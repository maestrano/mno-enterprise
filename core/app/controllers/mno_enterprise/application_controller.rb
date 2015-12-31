module MnoEnterprise
  class ApplicationController < ActionController::Base
    protect_from_forgery
    include ApplicationHelper
    prepend_before_filter :skip_devise_trackable_on_xhr

    before_filter :set_default_meta
    before_filter :store_location
    before_filter :perform_return_to
    before_filter :record_user_activity

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
      @meta[:title] = "Application"
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
      url = mno_enterprise.respond_to?(:myspace_url) ? mno_enterprise.myspace_url : main_app.root_url
      return (return_to_url(resource) || previous_url || url)
    end

    # Some controllers needs to redirect to 'MySpace' which breaks if you dont use mnoe-frontend
    # Rather than relying on the MainApp to define myspace_path we check it here
    # The MainApp can redefine this two methods to fit its structure
    # Some of these are extracted to individuals methods like after_provision_path.
    def mnoe_home_path
      mno_enterprise.respond_to?(:myspace_path) ? mno_enterprise.myspace_path : main_app.root_path
    end

    def mnoe_home_url
      mno_enterprise.respond_to?(:myspace_url) ? mno_enterprise.myspace_url : main_app.root_url
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      MnoEnterprise.router.after_sign_out_url || super
    end

    def record_user_activity
      if current_user
        current_user.last_active_at = Time.now.utc
        current_user.save
      end
    end
  end
end
