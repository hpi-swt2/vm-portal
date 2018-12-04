# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: 'landing#index'
  get '/dashboard' => 'dashboard#index', as: :dashboard
  resources :requests, path: '/vms/requests'

  get '/servers/:id' => 'servers#show', constraints: { id: /.*/ }

  devise_for :users, controllers: { registrations: 'users/registrations' }, path: 'users'
  resources :vms, :servers

  root 'landing#index'
end
