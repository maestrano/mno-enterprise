module MnoEnterprise
  module ApplicationHelper
    
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
