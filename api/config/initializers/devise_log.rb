Warden::Manager.after_authentication do |user,auth,opts|
  MnoEnterprise::EventLogger.new_event('user_login', user.id, "User login", user.email, user)
end

Warden::Manager.before_logout do |user,auth,opts|
  MnoEnterprise::EventLogger.new_event('user_logout', user.id, "User logout", user.email,user)
end
