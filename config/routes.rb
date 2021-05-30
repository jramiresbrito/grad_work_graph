Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/me', to: 'users#me'
      resources :users
      resources :sign_in, only: :create
      resources :categories
      resources :system_requirements
      resources :products
      resources :games, only: [], shallow: true do
        resources :licenses
      end
      resources :coupons
      resources :orders
    end
  end
end
