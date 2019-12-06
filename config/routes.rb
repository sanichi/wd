Rails.application.routes.draw do
  root to: "pages#home"
  get "signin" => "sessions#new"

  %w[help home contacts].each do |page|
    get page => "pages##{page}"
  end

  resources :blogs
  resources :books
  resources :games
  resources :players
  resources :users

  resource :session, only: [:new, :create, :destroy]

  resources :dragons, only: [:index]
  resources :journals, only: [:index]
end
