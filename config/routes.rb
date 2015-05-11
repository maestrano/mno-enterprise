MnoEnterprise::Engine.routes.draw do
  
  #============================================================
  # Static Pages
  #============================================================  
  root to: redirect { MnoEnterprise::Engine.routes.url_helpers.myspace_path }
  
  # Generic routes
  get '/launch/:id', to: 'pages#launch', constraints: { id: /[\w\-\.:]+/ }
  get '/loading/:id', to: 'pages#loading', constraints: { id: /[\w\-\.]+/ }
  get '/app_access_unauthorized', to: 'pages#app_access_unauthorized'
  get '/app_logout', to: 'pages#app_logout'
  
  # MySpace routes
  get '/myspace', to: 'pages#myspace'
  get '/myspace#/apps/dashboard', to: 'pages#myspace', as: 'myspace_home'
  get '/myspace#/billing', to: 'pages#myspace', as: 'myspace_billing'
  
  # App Provisioning
  resources :provision, only: [:new,:create]
  
  # Organization Invites
  resources :org_invites, only: [:show]
  
  #============================================================
  # Devise Configuration
  #============================================================
  devise_for :users, { 
    class_name: "MnoEnterprise::User",
    module: :devise, 
    path_prefix: 'auth',
    controllers: {
      confirmations: "mno_enterprise/auth/confirmations",
      #omniauth_callbacks: "auth/omniauth_callbacks",
      passwords: "mno_enterprise/auth/passwords",
      registrations: "mno_enterprise/auth/registrations",
      sessions: "mno_enterprise/auth/sessions",
      unlocks: "mno_enterprise/auth/unlocks"
    }
  }
  
  # TODO: routing specs
  devise_scope :user do
    get "/auth/users/confirmation/lounge", to: "auth/confirmations#lounge", as: :user_confirmation_lounge
    patch "/auth/users/confirmation/finalize", to: "auth/confirmations#finalize", as: :user_confirmation_finalize
    patch "/auth/users/confirmation", to: "auth/confirmations#update"
  end
  
  
  #============================================================
  # JPI V1
  #============================================================
  namespace :jpi do
    namespace :v1 do
      resources :marketplace, only: [:index,:show]
      resource :current_user, only: [:show, :update] do
        put :update_password
        #post :deletion_request, action: :create_deletion_request
        #delete :deletion_request, action: :cancel_deletion_request
      end
      
      resources :organizations, only: [:index, :show, :update] do
        member do
          put :invite_members
          put :update_member
          put :remove_member
        end
        
        # AppInstances
        resources :app_instances, only: [:index,:destroy], shallow: true
        
        # Currently stubbed
        resources :teams, only: [:index]
      end

      namespace :impac do
        resources :dashboards, only: [:index,:show,:create,:update,:destroy] do
          resources :widgets, shallow: true, only: [:show,:create,:destroy,:update]
        end
      end
    end
  end
end
