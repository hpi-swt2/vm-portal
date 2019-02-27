# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :app_settings, only: %i[update edit]
  resources :operating_systems, path: '/vms/requests/operating_systems', except: :show

  resources :request_templates, path: '/vms/request_templates', except: :show
  patch '/vms/requests/reject', to: 'requests#reject', as: 'reject'
  resources :requests, path: '/vms/requests' do
    post :push_to_git, on: :member
  end

  resources :notifications, only: %i[index new create destroy] do
    get :mark_as_read, on: :member
    get :has_any, on: :collection, to: 'notifications#any?'
    member do
      post 'destroy_and_redirect'
    end
  end

  get '/dashboard' => 'dashboard#index', as: :dashboard
  root to: 'landing#index'

  get '/hosts/:id' => 'hosts#show', constraints: { id: /.*/ }

  get '/vms/configs/:id' => 'vms#edit_config', constraints: { id: /.*/ }, as: :edit_config
  patch '/vms/configs/:id' => 'vms#update_config', constraints: { id: /.*/ }, as: :update_config

  # move all vm actions under /vms/vm because a VM named requests might otherwise lead to issues!
  post '/vms/vm/:id/change_power_state' => 'vms#change_power_state', constraints: { id: /.*/ }
  post '/vms/vm/:id/suspend_vm' => 'vms#suspend_vm', constraints: { id: /.*/ }
  post '/vms/vm/:id/shutdown_guest_os' => 'vms#shutdown_guest_os', constraints: { id: /.*/ }
  post '/vms/vm/:id/reboot_guest_os' => 'vms#reboot_guest_os', constraints: { id: /.*/ }
  post '/vms/vm/:id/reset_vm' => 'vms#reset_vm', constraints: { id: /.*/ }
  post '/vms/vm/:id/request_vm_archivation' => 'vms#request_vm_archivation', constraints: { id: /.*/ }
  post '/vms/vm/:id/archive_vm' => 'vms#archive_vm', constraints: { id: /.*/ }
  post '/vms/vm/:id/request_vm_revive' => 'vms#request_vm_revive', constraints: { id: /.*/ }
  post '/vms/vm/:id/revive_vm' => 'vms#revive_vm', constraints: { id: /.*/ }
  post '/vms/vm/:id/stop_archiving' => 'vms#stop_archiving', constraints: { id: /.*/ }
  resources :vms, except: %i[new create], path: 'vms/vm'

  get 'slack/new' => 'slack#new', as: :new_slack
  get 'slack/auth' => 'slack#update', as: :update_slack

  devise_for :users,
             path: 'users',
             controllers: {
               registrations: 'users/registrations',
               omniauth_callbacks: 'users/omniauth_callbacks'
             }

  resources :hosts, :servers
  resources :users do
    member do
      patch :update_role
    end
  end

  resources :projects, only: %i[index show new edit create update]

  root 'landing#index'
end
