Rails.application.routes.draw do
  root to: "pages#home"
  get "signin" => "sessions#new"

  %w[home].each do |page|
    get page => "pages##{page}"
  end

  resource :session, only: [:new, :create, :destroy]

  resources :blogs do
    get :pin, on: :member
  end
  resources :users
end
