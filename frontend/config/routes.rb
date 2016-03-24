MnoEnterprise::Engine.routes.draw do

  #============================================================
  # Static Pages
  #============================================================
  root to: redirect { MnoEnterprise.router.dashboard_path }

  # Invoices
  resources :invoices, only: [:show], constraints: { id: /[\w\-]+/ }
end
