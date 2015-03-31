module MnoEnterprise
  class ApplicationController < ActionController::Base
    protect_from_forgery
    include ApplicationHelper
    prepend_before_filter :skip_devise_trackable_on_xhr
  
    before_filter :mock_current_user
    before_filter :set_default_meta
    before_filter :store_location
    
    #============================================
    # CanCan Authorization Rescue
    #============================================
    # Rescue the CanCan permission denied error
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.html { redirect_to root_url, :alert => 'Unauthorized Action' }
        format.json { render :json => 'Unauthorized Action', :status => :forbidden }
      end
    end
    
    def set_default_meta
      @meta = {}
      @meta[:title] = "Application"
      @meta[:description] = "Enterprise Applications"
    end
    
    def mock_current_user
      #puts "---------------------- Current User -----------------------------"
      #puts current_user.inspect
      
      # unless current_user
      #   begin
      #     #puts "just before sign_in"
      #     sign_in MnoEnterprise::User.find(205), bypass: true
      #     #puts "current user after sign_in"
      #     #puts current_user.inspect
      #   rescue Exception => e
      #     puts "sign_in error"
      #     puts e
      #   end
      # end
      #puts "-----------------------------------------------------------------"
      true
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
  
      # Devise will always redirect to the last non devise route
      # (alias not starting with /auth)
      # ---
      # WARNING: if one day you change the below please also check that
      # the new behaviour fits with ConfirmationsController (yes...I know...it's not clean)
      def store_location
        # store last url if the request is html (not json or other)
        # and matches a specific action
        if request.format == 'text/html' && request.fullpath =~ /\/(myspace|deletion_requests|org_invites)/
          session[:previous_url] = request.original_url
        end
      end

      # Redirect to previous url and reset it
      def after_sign_in_path_for(resource)
        previous_url = session[:previous_url]
        session[:previous_url] = nil
        return (previous_url || mno_enterprise.myspace_url)
      end
  end
end
