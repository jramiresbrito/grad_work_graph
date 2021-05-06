Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      resources :sign_in, only: :create
      resources :categories
    end
  end
end
