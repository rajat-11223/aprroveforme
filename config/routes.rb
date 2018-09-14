Workflow::Application.routes.draw do
  post 'form_submission/create', as: :form_submission
  get "pricing", as: :pricing, to: "pricing#index"

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

      get :current_subscription
      get :subscription_histories
      get :manage_subscription

      get :active_approvals
      get :completed_approvals

      get :pending_approvals
      get :signed_off_approvals
    end
  end

  get "/#{Rails.application.config.google_verification}.html",
      to: proc { |env| [200, {}, ["google-site-verification: #{Rails.application.config.google_verification}.html"]] }

  constraints SignedIn.new { |user| user.user.has_role?(:admin) } do
    mount Split::Dashboard, at: 'split'
  end

  get "/bomb", to: "errors#bomb"

  resources :users, only: [:index, :show, :edit, :update]

  get '/auth/:provider/callback' => 'sessions#create', as: :oauth_callback
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  get '/getstarted/:intro' => 'home#index'

  resources :home do
    collection do
      get :dashboard
      get :pending_approvals
      get :open_approvals
      get :past_documents
      get :past_approvals
    end
  end

  resource :subscription, only: [:new, :create, :update] do
    get :continue_permission, on: :collection
  end

  # Static Pages
  get "/*id" => 'pages#show', as: :page, format: false

  root to: "home#index"
end
