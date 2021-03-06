require "sidekiq/web"
require "sidekiq/cron/web"

Workflow::Application.routes.draw do
  mount_griddler("/incoming/email")

  resources :approvals do
    resources :approvers
    resources :tasks
  end

  resources :responses, only: [:show, :update]

  resource :account do
    get :activate
    get :need_to_activate
    post :need_to_activate
    get :profile
    patch :profile_update

    # Payment management
    get :payment_methods
    delete :delete_payment_method
    post :add_new_payment_method
    patch :set_default_payment_method

    # Subscription management
    get :current_subscription
    get :subscription_histories
  end

  resources :home do
    collection do
      get :dashboard

      get :open_requests
      get :complete_requests

      get :open_responses
      get :complete_responses
    end
  end

  resource :subscription, only: [:new, :create, :update] do
    get :continue_permission, on: :collection
  end

  # Form submission
  post "form_submission/create", as: :form_submission

  # Admins-only
  constraints SignedIn.new { |user| user.user.has_role?(:admin) } do
    mount Split::Dashboard, at: "split"
    mount Sidekiq::Web => "/sidekiq"
    ActiveAdmin.routes(self)
  end

  # Google Verification
  get "/#{Rails.application.config.google_verification}.html",
      to: proc { |env| [200, {}, ["google-site-verification: #{Rails.application.config.google_verification}.html"]] }
  get "/#{Rails.application.config.startup_ranking_verification}.html",
      to: proc { |env| [200, {}, ["startupranking-site-verification: #{Rails.application.config.startup_ranking_verification}.html"]] }

  # Authentication
  get "/auth/:provider/callback" => "sessions#create", as: :oauth_callback
  get "/signin" => "sessions#new", :as => :signin
  get "/signout" => "sessions#destroy", :as => :signout
  get "/auth/failure" => "sessions#failure"
  get "/getstarted/:intro" => "home#index"

  # Static Pages
  get "pricing", as: :pricing, to: "pricing#index"
  get "/*id" => "pages#show", as: :page, format: false
  get "/bomb", to: "errors#bomb"

  root to: "home#index"
end
