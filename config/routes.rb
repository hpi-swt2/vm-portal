# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :requests, path: '/vms/requests'

  root to: redirect('/users/sign_in')

  get '/server/:id' => 'server#show', constraints: { id: /.*/ }

  devise_for :users, controllers: { registrations: 'users/registrations' }, path: 'users'
  resources :vms, :server

  root 'landing#index'
end
