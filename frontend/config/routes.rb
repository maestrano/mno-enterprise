MnoEnterprise::Engine.routes.draw do

  #============================================================
  # Static Pages
  #============================================================
  root to: redirect { MnoEnterprise::Engine.routes.url_helpers.myspace_path }

  # MySpace routes
  get '/myspace', to: 'pages#myspace'
  get '/myspace#/apps/dashboard', to: 'pages#myspace', as: 'myspace_home'
  get '/myspace#/billing', to: 'pages#myspace', as: 'myspace_billing'

  # Invoices
  resources :invoices, only: [:show], constraints: { id: /[\w\-]+/ }

  # User Setup process
  # ==> Currently NOT prod ready
  resources :user_setup, only: [:index]
end
