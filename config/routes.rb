# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :operating_systems, path: '/vms/requests/operating_systems', except: :show
  patch 'requests/request_accept_button', to: 'requests#request_accept_button', as: 'request_accept_button'
  resources :requests, path: '/vms/requests'

  root to: redirect('/vms')

  get '/servers/:id' => 'servers#show', constraints: { id: /.*/ }
  post '/vms/:id/change_power_state' => 'vms#change_power_state', constraints: { id: /.*/ }
  post '/vms/:id/suspend_vm' => 'vms#suspend_vm', constraints: { id: /.*/ }
  post '/vms/:id/shutdown_guest_os' => 'vms#shutdown_guest_os', constraints: { id: /.*/ }
  post '/vms/:id/restart_guest_os' => 'vms#restart_guest_os', constraints: { id: /.*/ }
  post '/vms/:id/reset_vm' => 'vms#reset_vm', constraints: { id: /.*/ }

  get 'slack/new' => 'slack#new', as: :new_slack
  get 'slack/auth' => 'slack#update', as: :update_slack

  devise_for :users, controllers: { registrations: 'users/registrations' }, path: 'users'
  resources :vms, :servers
  resources :users, only: %i[show index]

  root 'landing#index'
end
