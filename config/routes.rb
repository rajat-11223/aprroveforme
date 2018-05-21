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
  get 'payments/new' => 'payments#new', :as => :new_payment
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
end
