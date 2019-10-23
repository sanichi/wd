Rails.application.routes.draw do
  root to: "pages#home"
  get "signin" => "sessions#new"

  %w[home].each do |page|
    get page => "pages##{page}"
  end

  resource :session, only: [:new, :create, :destroy]

  resources :blogs
  resources :players
  resources :users
end
