Warden::Manager.after_authentication do |user, auth, opts|
  MnoEnterprise::EventLogger.info('user_login', user.id, "User login", user.email, user)
end

Warden::Manager.before_logout do |user, auth, opts|
  # Determine whether it's a sign out or timeout
  if auth.env['PATH_INFO'] =~ %r{^/auth/users/sign_out.json$}
    MnoEnterprise::EventLogger.info('user_logout', user.id, "User logout", user.email, user)
  else
    MnoEnterprise::EventLogger.info('user_timeout', user.id, "User session expired", user.email, user)
  end
end
