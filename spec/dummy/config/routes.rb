Rails.application.routes.draw do
  
  # MnoEnterprise Engine
  mount MnoEnterprise::Engine => "/mnoe", as: :mno_enterprise
  
  # Root to login page
  root to: redirect('/mnoe/auth/users/sign_in')
end
