module MnoEnterprise
  class ApplicationController < ActionController::Base
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
  end
end
