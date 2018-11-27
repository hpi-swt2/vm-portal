# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  patch 'requests/request_accept_button', to: 'requests#request_accept_button', as: 'request_accept_button'
  resources :requests
  root to: redirect('/users/sign_in')

  get '/host/:id' => 'vm#show_host', constraints: { id: /.*/ }

  devise_for :users, path: 'users'
  resources :vm

  root 'landing#index'
end
