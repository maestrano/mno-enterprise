module MnoEnterprise
  module ApplicationHelper
    
    # Re-implement Devise filter
    # For some reasons the original Devise filter seems to ignore the
    # mnoe prefix when using custom devise controllers
    def authenticate_user!
      redirect_to(new_user_session_path) unless current_user
      true
    end
    
    # Redirect a signed in user to the confirmation
    # lounge if unconfirmed
    def redirect_to_lounge_if_unconfirmed
      if current_user && !current_user.confirmed?
        redirect_to user_confirmation_lounge_path
      end
      return true
    end
    
  end
end
