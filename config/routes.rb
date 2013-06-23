Workflow::Application.routes.draw do
  get "faq/index"

  get "privacy/index"

  get "terms/index"

  get "about/index"

  resources :approvals do
  	resources :approvers
    resources :tasks
  end

  mount Split::Dashboard, :at => 'split'

  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
end
