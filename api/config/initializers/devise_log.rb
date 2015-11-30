Warden::Manager.after_authentication do |user,auth,opts|
  MnoEnterprise::EventLogger.info('user_login', user.id, "User login", user.email, user)
end

Warden::Manager.before_logout do |user,auth,opts|
  MnoEnterprise::EventLogger.info('user_logout', user.id, "User logout", user.email,user)
end
