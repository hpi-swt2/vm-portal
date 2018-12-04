# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  patch 'requests/accept!', to: 'requests#accept!', as: 'accept_request'
  resources :requests
  root to: redirect('/users/sign_in')

  get '/server/:id' => 'server#show', constraints: { id: /.*/ }

  devise_for :users, path: 'users'
  resources :vm, :server

  root 'landing#index'
end
