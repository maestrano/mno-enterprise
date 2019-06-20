# After each sign in, update sso_session.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication. Retrieving the user from session (:fetch) does
# not trigger it.
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  if Settings&.authentication&.session_limitable&.enabled
    if warden.authenticated?(options[:scope])
      warden.session(options[:scope])['sso_session'] = record.sso_session
    end
  end
end

# Each time a record is fetched from session we check if a new session from another
# browser was opened for the record or not, based on a unique session identifier.
# If so, the old account is logged out and redirected to the sign in page on the next request.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  scope = options[:scope]
  env   = warden.request.env  

  if Settings&.authentication&.session_limitable&.enabled
    if warden.authenticated?(scope) && options[:store] != false
      if record.sso_session != warden.session(scope)['sso_session'] && !env['devise.skip_session_limitable']
        warden.raw_session.clear
        warden.logout(scope)
        throw :warden, :scope => scope, :message => :session_limited
      end
    end
  end
end
