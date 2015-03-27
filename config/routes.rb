MnoEnterprise::Engine.routes.draw do
  
  #============================================================
  # Static Pages
  #============================================================
  root to: "application#index"
  
  #============================================================
  # Devise Configuration
  #============================================================
  devise_for :users, { 
    class_name: "MnoEnterprise::User",
    module: :devise, 
    path_prefix: 'auth' 
  }
  
  #============================================================
  # JPI V1
  #============================================================
  namespace :jpi do
    namespace :v1 do
      resources :marketplace, only: [:index,:show]
    end
  end
end
