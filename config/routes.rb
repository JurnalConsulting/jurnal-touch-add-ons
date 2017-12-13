Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  get 'home/dashboard'

  resources :settings do
    resources :payment_methods
    resources :devices, only: [:destroy]
  end

  resources :select2_ajax_resources, only: [] do
    collection do
      get :get_warehouse
      get :get_tag
      get :get_account
    end
  end

  namespace :api do
    namespace :v1 do
      match :login, to: 'login#destroy', via: 'delete', defaults: { id: nil }
      resources :login, only:[:create, :destroy] do
        collection do
          get :refresh
        end
      end
      resources :products, only: [:index] 
      resources :payment_methods, only: [:index]
      resources :sales_invoice, only: [:create]
    end
  end
end
