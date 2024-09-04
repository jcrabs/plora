Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :maps do
    post "/segments/track", to: "segments#import_track", as: "import_track"
    post "/segments/drawing", to: "segments#import_drawing", as: "import_drawing"

    resources :annotations, only: [:create, :update, :destroy, :index]
  end

end
