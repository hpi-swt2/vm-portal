# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :operating_systems, path: '/vms/requests/operating_systems', except: :show
  patch 'requests/request_change_state', to: 'requests#request_change_state', as: 'request_change_state'
  resources :request_templates, path: '/vms/request_templates', except: :show
  resources :requests, path: '/vms/requests'
  resources :notifications, only: %i[index new create destroy] do
    get :mark_as_read, on: :member
    get :has_any, on: :collection, to: 'notifications#any?'
  end

  get '/dashboard' => 'dashboard#index', as: :dashboard
  root to: 'landing#index'

  get '/hosts/:id' => 'hosts#show', constraints: { id: /.*/ }
  post '/vms/:id/change_power_state' => 'vms#change_power_state', constraints: { id: /.*/ }
  post '/vms/:id/suspend_vm' => 'vms#suspend_vm', constraints: { id: /.*/ }
  post '/vms/:id/shutdown_guest_os' => 'vms#shutdown_guest_os', constraints: { id: /.*/ }
  post '/vms/:id/reboot_guest_os' => 'vms#reboot_guest_os', constraints: { id: /.*/ }
  post '/vms/:id/reset_vm' => 'vms#reset_vm', constraints: { id: /.*/ }
  post '/vms/:id/request_vm_archivation' => 'vms#request_vm_archivation', constraints: { id: /.*/ }
  post '/vms/:id/archive_vm' => 'vms#archive_vm', constraints: { id: /.*/ }
  post '/vms/:id/request_vm_revive' => 'vms#request_vm_revive', constraints: { id: /.*/ }
  post '/vms/:id/revive_vm' => 'vms#revive_vm', constraints: { id: /.*/ }
  post '/vms/:id/stop_archiving' => 'vms#stop_archiving', constraints: { id: /.*/ }

  get 'slack/new' => 'slack#new', as: :new_slack
  get 'slack/auth' => 'slack#update', as: :update_slack

  devise_for :users,
             path: 'users',
             controllers: {
               registrations: 'users/registrations',
               omniauth_callbacks: 'users/omniauth_callbacks'
             }

  resources :vms, :hosts, :servers
  resources :users do
    member do
      patch :update_role
    end
  end

  resources :projects, only: %i[index show new edit create update]

  root 'landing#index'
end
