Workflow::Application.routes.draw do
  get "pricing/index"

  get "faq/index"

  get "privacy/index"

  get "terms/index"

  get "about/index"

  resources :approvals do
  	resources :approvers
    resources :tasks
  end
  match 'payments/new' => 'payments#new', :as => :new_payment
  match 'payments/confirm' => 'payments#confirm', :as => :confirm_payment

  match "/#{Rails.application.config.google_verification}.html",
  to: proc { |env| [200, {},
    ["google-site-verification:
    #{Rails.application.config.google_verification}.html"]] }

  mount Split::Dashboard, :at => 'split'

  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
  match '/getstarted/:intro' => 'home#index'
end
