MnoEnterprise::Engine.routes.draw do
  # Generic routes
  get '/launch/:id', to: 'pages#launch', constraints: {id: /[\w\-\.:]+/}
  get '/loading/:id', to: 'pages#loading', constraints: {id: /[\w\-\.]+/}
  get '/app_access_unauthorized', to: 'pages#app_access_unauthorized'
  get '/billing_details_required', to: 'pages#billing_details_required'
  get '/app_logout', to: 'pages#app_logout'
  get '/terms', to: 'pages#terms'

  # Health Status
  get '/ping', to: 'status#ping'
  get '/version', to: 'status#version'
  get 'health_check(/:checks)(.:format)', to: '/health_check/health_check#index'

  get 'config', to: 'config#show'

  # App Provisioning
  resources :provision, only: [:new, :create]

  # Organization Invites
  resources :org_invites, only: [:show]

  resources :deletion_requests, only: [:show] do
    member do
      patch :freeze_account
      patch :checkout
      put :terminate_account
    end
  end

  # Invoices
  namespace :admin do
    resources :invoices, only: [:show], constraints: { id: /[\w\-]+/ }
  end

  if Settings&.admin_panel&.impersonation&.enabled
    get "/impersonate/user/:user_id", to: "impersonate#create", as: :impersonate_user
    get "/impersonate/revert", to: "impersonate#destroy", as: :revert_impersonate_user
  end

  #============================================================
  # Devise/User Configuration
  #============================================================
  # Main devise configuration
  skipped_devise_modules = [:omniauth_callbacks]
  skipped_devise_modules << :registrations unless Settings&.dashboard&.registration&.enabled
  devise_for :users, {
      class_name: "MnoEnterprise::User",
      module: :devise,
      path_prefix: 'auth',
      skip: skipped_devise_modules,
      controllers: {
          confirmations: "mno_enterprise/auth/confirmations",
          omniauth_callbacks: "mno_enterprise/auth/omniauth_callbacks",
          passwords: "mno_enterprise/auth/passwords",
          registrations: "mno_enterprise/auth/registrations",
          sessions: "mno_enterprise/auth/sessions",
          unlocks: "mno_enterprise/auth/unlocks"
      }
  }

  # Additional devise routes
  # TODO: routing specs
  devise_scope :user do
    get "/auth/users/confirmation/lounge", to: "auth/confirmations#lounge", as: :user_confirmation_lounge
    patch "/auth/users/confirmation/finalize", to: "auth/confirmations#finalize", as: :user_confirmation_finalize
    patch "/auth/users/confirmation", to: "auth/confirmations#update"

    # Patch omniauth routes as per plataformatec/devise#2692
    providers = Regexp.union(Devise.omniauth_providers.map(&:to_s))
    match "/users/auth/:provider",
          constraints: { provider: providers },
          to: "auth/omniauth_callbacks#passthru",
          as: :user_omniauth_authorize,
          via: [:get, :post]
    match "/users/auth/:action/callback",
          constraints: { action: providers },
          controller: "auth/omniauth_callbacks",
          as: :user_omniauth_callback,
          via: [:get, :post]
  end

  #============================================================
  # Webhooks
  #============================================================
  namespace :webhook do
    # OAuth Management
    resources :oauth, only: [], constraints: {id: /[\w\-\.:]+/}, controller: "o_auth" do
      member do
        get :authorize
        get :callback
        get :disconnect
        get :sync
      end
    end
    # Maestrano-hub events
    resources :events, only: [:create]
  end

  #============================================================
  # JPI V1
  #============================================================
  namespace :jpi do
    namespace :v1 do
      resources :invoices, only: [:show], constraints: { id: /[\w\-]+/ }
      resources :system_identity, only: [:index]

      resources :marketplace, only: [:index, :show] do
        member do
          %i(app_reviews app_feedbacks app_comments app_questions app_answers).each do |name|
            resources name, except: [:new, :edit], param: :review_id
          end
        end
      end

      resource :current_user, only: [:show, :update] do
        put :update_password
        put :register_developer
      end

      resources :user_access_requests, only: [:index, :create] do
        collection do
          get :last_access_request
        end
        member do
          put :approve
          put :deny
          put :revoke
        end
      end

      resources :organizations, only: [:index, :show, :create, :update, :destroy] do
        member do
          put :update_billing
          put :invite_members
          put :update_member
          put :remove_member
        end

        # AppInstances
        resources :app_instances, only: [:index, :create, :destroy], shallow: true

        # Teams
        resources :teams, only: [:index, :show, :create, :update, :destroy], shallow: true do
          member do
            put :add_users
            put :remove_users
          end
        end

        resources :app_instances_sync, only: [:create, :index]

        resources :audit_events, only: [:index]

        if Settings&.dashboard&.marketplace&.provisioning
          resources :subscriptions, only: [:index, :show, :create, :update] do
            member do
              post :cancel
            end

            resources :subscription_events, only: [:index, :show]
          end
        end
      end

      resources :deletion_requests, only: [:show, :create, :destroy] do
        member do
          put :resend
        end
      end

      namespace :impac do
        post 'dashboards/:id/copy', to: 'dashboards#copy'

        resources :dashboards, only: [:index, :show, :create, :update, :destroy] do
          resources :widgets, shallow: true, only: [:create, :update, :destroy]
          resources :kpis, shallow: true, only: [:show, :create, :update, :destroy] do
            resources :alerts, shallow: true, only: [:create, :update, :destroy]
          end
        end

        resources :kpis, only: :index
        resources :alerts, only: :index

        resources :organizations, only: [] do
          resources :widgets, only: :index
        end

        resources :dashboard_templates, only: :index
      end

      resources :products, only: [:index, :show] do
        resources :pricings, only: :index
      end

      #============================================================
      # Admin
      #============================================================
      namespace :admin, defaults: {format: 'json'} do

        resources :assets, only: [:index, :show, :create, :destroy]
        resources :audit_events, only: [:index]
        resources :app_feedbacks, only: [:index]
        resources :app_questions, only: [:index]
        resources :app_instances, only: [:destroy], shallow: true
        resources :app_reviews, only: [:index, :show,  :update]
        resources :app_comments, only: [:create]
        resources :app_answers, only: [:create]

        resources :apps, only: [:index] do
          collection do
            patch :enable
          end
          member do
            patch :enable
            patch :disable
          end
        end

        resources :users, only: [:index, :show, :destroy, :update, :create] do
          collection do
            get :metrics
            post :signup_email
          end
          resource :user_access_requests, only: [:create]
          member do
            patch :update_clients
          end
        end

        resources :products, only: [:index, :show]

        if Settings&.dashboard&.marketplace&.local_products
          resources :products, only: [:index, :show, :destroy, :update, :create] do
            member do
              post :upload_logo
            end

            resources :assets, only: [:index, :create]
          end
        end

        if Settings&.dashboard&.marketplace&.provisioning
          resources :subscriptions, only: [:index]
        end

        resources :organizations, only: [:index, :show, :update, :create] do
          collection do
            get :in_arrears
            get :count
            get :download_batch_example
            post :batch_import
          end
          member do
            post :users, action: :invite_member
            put :update_member
            put :remove_member
            put :freeze, action: :freeze_account
            put :unfreeze
          end
          resources :users, only: [] do
            resource :invites, only: [:create]
          end

          resources :teams, only: [:index]

          if Settings&.dashboard&.marketplace&.provisioning
            resources :subscriptions, only: [:index, :show, :create, :update] do
              member do
                post :cancel
                post :approve
                post :fulfill
              end

              resources :subscription_events, only: [:index, :show]
            end
          end
        end

        resources :sub_tenants, only: [:index, :show, :destroy, :update, :create] do
          member do
            patch :update_clients
            patch :update_account_managers
          end
        end

        resources :tenant_invoices, only: [:index, :show]

        resources :invoices, only: [:index, :show, :update] do
          collection do
            get :current_billing_amount
            get :last_invoicing_amount
            get :outstanding_amount
            get :last_commission_amount
            get :last_portfolio_amount
          end

          member do
            post :adjustments, action: :create_adjustment
            delete 'adjustments/:bill_id', action: :delete_adjustment
            post :send_to_customer
          end
        end

        resources :cloud_apps, only: [:index, :update] do
          member do
            put :regenerate_api_key
            put :refresh_metadata
          end
        end

        resource 'tenant', only: [:show, :update] do
          member do
            get :restart_status
            post :ssl_certificates, action: :add_certificates
            match :domain, action: :update_domain, via: [:put, :patch]
          end
        end

        resources :app_metrics, only: [:index, :show]

        if Settings&.dashboard&.marketplace&.product_markup
          resources :product_markups, only: [:index, :show, :destroy, :update, :create]
        end

        # Theme Previewer
        post 'theme/save'
        post 'theme/reset'
        put 'theme/logo'

        # Dashboard templates designer
        namespace :impac do
          resources :dashboard_templates, only: [:index, :show, :destroy, :update, :create] do
            resources :widgets, shallow: true, only: [:create, :update, :destroy]
            resources :kpis, shallow: true, only: [:create, :update, :destroy]
          end
        end
      end
    end
  end
end
