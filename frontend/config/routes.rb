MnoEnterprise::Engine.routes.draw do

  #============================================================
  # Static Pages
  #============================================================
  root to: redirect { MnoEnterprise::Engine.routes.url_helpers.myspace_path }

  # Generic routes
  get '/launch/:id', to: 'pages#launch', constraints: { id: /[\w\-\.:]+/ }
  get '/loading/:id', to: 'pages#loading', constraints: { id: /[\w\-\.]+/ }
  get '/app_access_unauthorized', to: 'pages#app_access_unauthorized'
  get '/billing_details_required', to: 'pages#billing_details_required'
  get '/app_logout', to: 'pages#app_logout'

  # MySpace routes
  get '/myspace', to: 'pages#myspace'
  get '/myspace#/apps/dashboard', to: 'pages#myspace', as: 'myspace_home'
  get '/myspace#/billing', to: 'pages#myspace', as: 'myspace_billing'

  # App Provisioning
  resources :provision, only: [:new,:create]

  # Invoices
  resources :invoices, only: [:show], constraints: { id: /[\w\-]+/ }

  # User Setup process
  # ==> Currently NOT prod ready
  resources :user_setup, only: [:index]
end
