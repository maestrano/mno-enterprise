MnoEnterprise::Engine.routes.draw do

  #============================================================
  # Static Pages
  #============================================================
  root to: redirect { MnoEnterprise.router.dashboard_path }

  # Invoices
  resources :invoices, only: [:show], constraints: { id: /[\w\-]+/ }

  # User Setup process
  # ==> Currently NOT prod ready
  resources :user_setup, only: [:index]
end
