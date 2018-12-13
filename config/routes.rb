# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :operating_systems, path: '/vms/requests/operating_systems', except: :show
  patch 'requests/request_accept_button', to: 'requests#request_accept_button', as: 'request_accept_button'
  resources :requests, path: '/vms/requests'

  # root to: redirect('/vms')

  get '/servers/:id' => 'servers#show', constraints: { id: /.*/ }

  get 'slack/new' => 'slack#new', as: :new_slack
  get 'slack/auth' => 'slack#update', as: :update_slack

  devise_for :users, controllers: { sessions: 'sessions', registrations: 'users/registrations' }, path: 'users'
  resources :vms, :servers
  resources :users, only: %i[show index]

  root 'landing#index'
end
