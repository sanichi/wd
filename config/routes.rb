Rails.application.routes.draw do
  root to: "pages#home"
  get "signin" => "sessions#new"

  %w[help home].each do |page|
    get page => "pages##{page}"
  end

  resources :blogs
  resources :books
  resources :dragons, only: [:index]
  resources :games
  resources :journals, only: [:index]
  resources :players do
    get :contacts, on: :collection
    get :registration, on: :collection
  end
  resources :users

  resource :session, only: [:new, :create, :destroy]
end
