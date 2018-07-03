Workflow::Application.routes.draw do
  resources :how_it_works, only: [ :index ]

  get "pricing/index"

  get "faq/index"

  get "privacy/index"

  get "terms/index"

  get "about/index"

  resources :approvals do
  	resources :approvers
    resources :tasks
  end

  resource :account do
    collection do
      get :profile

      get :payment_methods
      get :delete_payment_method
      post :add_new_payment_method
      get :set_default_payment_method

      get :update_card
      post :update_card_post

      get :current_subscription
      get :subscription_histories
      get :manage_subscription

      get :active_approvals
      get :completed_approvals

      get :pending_approvars
      get :signed_off_approvars
    end
  end

  get 'payments_methods' => 'payments#index', :as => :payment_methods
  get 'payments_method/update' => 'payments#update', :as => :payment_method_update
  post 'payments' => 'payments#create', :as => :payment
  get 'payments/confirm' => 'payments#confirm', :as => :confirm_payment

  get "/#{Rails.application.config.google_verification}.html",
  to: proc { |env| [200, {},
    ["google-site-verification: #{Rails.application.config.google_verification}.html"]] }

  mount Split::Dashboard, :at => 'split'

  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  get '/getstarted/:intro' => 'home#index'

  resources :home do
    collection do
      get :pending_approvals
      get :open_approvals
      get :past_documents
      get :past_approvals
    end
  end
  resource :subscription do
    collection do
      get :upgrade
      get :continue_permission
    end
  end

end
