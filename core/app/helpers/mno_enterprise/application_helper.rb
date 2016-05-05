module MnoEnterprise
  module ApplicationHelper
    
    def support_email
      MnoEnterprise.support_email
    end
    
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
    
    # Redirect to signup page if user not authenticated
    def authenticate_user_or_signup!
      unless current_user
        redirect_to new_user_registration_path
        false
      end
    
      true
    end
    
    def notice_hash(notice)
      return {} unless notice
      # TODO: refactor
      auto_close = (notice =~ /signed (in|out)/i ? 5*1000 : nil)
      # Check if a timeout has been defined in flash
      unless auto_close
        auto_close = flash[:flash_options][:timeout] if flash[:flash_options] && flash[:flash_options][:timeout]
      end

      {
        type:'success',
        msg: (notice || '').html_safe,
        timeout: auto_close
      }
    end

    def alert_hash(alert)
      return {} unless alert
      {
        type:'danger',
        msg: (alert || '').html_safe,
        timeout: -1
      }
    end

    # This helper converts markdown content
    # to html, using the HtmlProcessor (see /lib)
    def markdown(text)
      return text unless text.present?
      HtmlProcessor.new(text, format: :markdown).html.html_safe
    end

    # Return the user avatar url. The displayed picture use the gravatar of the user email
    # TODO: add and use avatar_email from the OAUTH user
    def avatar_url(user)
      gravatar_url(user.email)
    end

    # Return the gravatar url for the given email
    def gravatar_url(email)
      if email
        gravatar_id = Digest::MD5.hexdigest(email.downcase)
        "https://gravatar.com/avatar/#{gravatar_id}.png?s=50&d=mm"
      end
    end
  end
end
