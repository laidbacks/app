Rails.application.routes.draw do
  get "pages/signup"
  get "users/new"
  get "users/create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  get "/signup", to: "users#signup"
  post "/signup", to: "users#create"

  get "/profile", to: "users#show"

  # Habits routes
  resources :habits do
    patch "toggle_today", on: :member
    resources :habit_logs, shallow: true
  end

  # Sessions routes for login/logout
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # API routes
  namespace :api do
    resources :habits do
      resources :habit_logs, shallow: true
      member do
        get :stats # GET /api/habits/:id/stats
      end
      collection do
        get :active, to: "habits#index", defaults: { active: true }
      end
      patch :toggle_today, to: "habit_logs#toggle_today"
    end

    resources :habit_logs, only: [ :index ]
  end
end
