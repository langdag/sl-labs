Rails.application.routes.draw do
  root "home#index"

  resources :registrations, only: [:new, :create]
  get "signup", to: "registrations#new"

  resource :session, controller: "authentication", only: [:new, :create, :destroy]
  get "login", to: "authentication#new"
  delete "logout", to: "authentication#destroy"
  post "login", to: "authentication#login" # Keep legacy API login

  resources :passwords, param: :token

  resources :repositories, only: [:index, :new, :create]

  resource :profile, only: [:edit, :update]
  get "up" => "rails/health#show", as: :rails_health_check

  get "/:username/:repository_name/tree/(:ref)(/*path)", to: "repositories#show", as: :repository_tree, constraints: { ref: /[^\/]+/ }, format: false
  get "/:username/:repository_name/blob/(:ref)(/*path)", to: "repositories#show", as: :repository_blob, constraints: { ref: /[^\/]+/ }, format: false
  get "/:username/:repository_name/commits", to: "commits#index", as: :repository_commits
  
  # Repository Management inside the slug
  scope "/:username/:repository_name" do
    get "/edit", to: "repositories#edit", as: :edit_repository_pretty
    patch "/", to: "repositories#update", as: :update_repository_pretty
    put "/", to: "repositories#update"
    delete "/", to: "repositories#destroy", as: :destroy_repository_pretty
  end

  get "/:username/:repository_name", to: "repositories#show", as: :repository_pretty_root

  get "/:username", to: "profiles#show", as: :user_profile
end
