# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :operating_systems, path: '/vms/requests/operating_systems', except: :show
  patch 'requests/request_accept_button', to: 'requests#request_accept_button', as: 'request_accept_button'
  resources :requests, path: '/vms/requests'
  resources :notifications, only: %i[index new create destroy] do
    member do
      get :mark_as_read
    end
  end

  get '/dashboard' => 'dashboard#index', as: :dashboard
  root to: 'landing#index'

  get '/hosts/:id' => 'hosts#show', constraints: { id: /.*/ }

  get 'slack/new' => 'slack#new', as: :new_slack
  get 'slack/auth' => 'slack#update', as: :update_slack

  devise_for :users,
             path: 'users',
             controllers: {
               registrations: 'users/registrations',
               omniauth_callbacks: 'users/omniauth_callbacks'
             }

  resources :vms, :hosts
  resources :users, only: %i[show index]
end
