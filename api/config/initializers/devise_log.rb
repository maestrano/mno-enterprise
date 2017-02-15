Warden::Manager.after_authentication do |user, auth, opts|
  MnoEnterprise::EventLogger.info('user_login', user.id, 'User login', user) if user
end

Warden::Manager.before_logout do |user, auth, opts|
  # Determine whether it's a sign out or timeout
  if auth.env['PATH_INFO'] =~ %r{^/auth/users/sign_out}
    MnoEnterprise::EventLogger.info('user_logout', user.id, 'User logout', user) if user
  else
    MnoEnterprise::EventLogger.info('user_timeout', user.id, 'User session expired', user) if user
  end
end
