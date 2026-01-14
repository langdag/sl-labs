Rails.application.routes.draw do
  root "home#index"

  resources :registrations, only: [:new, :create]
  get "signup", to: "registrations#new"

  resource :session, controller: "authentication", only: [:new, :create, :destroy]
  get "login", to: "authentication#new"
  delete "logout", to: "authentication#destroy"
  post "login", to: "authentication#login" # Keep legacy API login

  resources :passwords, param: :token

  resources :repositories do
    resources :commits, only: [:index]
    resources :trees, only: [:show], param: :sha
    resources :blobs, only: [:show], param: :sha
  end

  resource :profile, only: [:edit, :update]

  get "up" => "rails/health#show", as: :rails_health_check

  # Keep this at the bottom to avoid hijacking other routes
  get "/:username", to: "profiles#show", as: :user_profile
end
