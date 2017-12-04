module MnoEnterprise
  module ImpersonateHelper

    # current_user changes from a staff user to
    # +new_user+; current user stored in +session[:impersonator_user_id]+
    def impersonate(new_user)
      session[:impersonator_user_id] = current_user.id
      sign_out(current_user)
      sign_in new_user
      MnoEnterprise::EventLogger.info('impersonate_created', session[:impersonator_user_id], 'Impersonation started', new_user)
    end

    # revert the +current_user+ back to the staff user
    # stored in +session[:impersonator_user_id]+
    def revert_impersonate
      return unless current_impersonator
      sign_out(current_user)
      sign_in(current_impersonator)
      MnoEnterprise::EventLogger.info('impersonate_destroyed', session[:impersonator_user_id], 'Impersonation ended', current_user)
      session[:impersonator_user_id] = nil
    end

    def current_impersonator
      return unless session[:impersonator_user_id]
      @admin_user ||= MnoEnterprise::User.find_one(session[:impersonator_user_id])
    end

  end
end
