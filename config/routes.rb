MnoEnterprise::Engine.routes.draw do
  
  root to: "application#index"
  
  # Devise Configuration
  devise_for :users, { 
    class_name: "MnoEnterprise::User",
    module: :devise, 
    path_prefix: 'auth' 
  }
  
end
