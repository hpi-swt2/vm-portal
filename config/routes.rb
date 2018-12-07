# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :operating_systems, path: '/vms/requests/operating_systems', except: :show
  patch 'requests/request_accept_button', to: 'requests#request_accept_button', as: 'request_accept_button'
  resources :requests, path: '/vms/requests'

  root to: redirect('/vms')

  get '/servers/:id' => 'servers#show', constraints: { id: /.*/ }
  post '/change_power_state_index' => 'vms#change_power_state_on_index'
  post '/change_power_state_show' => 'vms#change_power_state_on_show'
  post '/suspend_vm' => 'vms#suspend_vm'
  post '/shutdown_guest_os' => 'vms#shutdown_guest_os'
  post '/restart_guest_os' => 'vms#restart_guest_os'
  post '/reset_vm' => 'vms#reset_vm'

  get 'slack/new' => 'slack#new', as: :new_slack
  get 'slack/auth' => 'slack#update', as: :update_slack

  devise_for :users, controllers: { registrations: 'users/registrations' }, path: 'users'
  resources :vms, :servers
  resources :users, only: %i[show index]

  root 'landing#index'
end
