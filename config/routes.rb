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
    delete :destroy_and_redirect, on: :member
  end

  get '/dashboard' => 'dashboard#index', as: :dashboard
  root to: 'landing#index'

  get '/hosts/:id' => 'hosts#show', constraints: { id: /.*/ }

  get '/vms/configs/:id' => 'vms#edit_config', constraints: { id: /.*/ }, as: :edit_config
  patch '/vms/configs/:id' => 'vms#update_config', constraints: { id: /.*/ }, as: :update_config

  # move all vm actions under /vms/vm because a VM named requests might otherwise lead to issues!
  resources :vms, except: [:new, :create], path: 'vms/vm', constraints: { id: /.*/ } do
    # https://guides.rubyonrails.org/routing.html#adding-member-routes
    member do
      post 'change_power_state'
      post 'suspend_vm'
      post 'shutdown_guest_os'
      post 'reboot_guest_os'
      post 'reset_vm'
      post 'request_vm_archivation'
      post 'archive_vm'
      post 'request_vm_revive'
      post 'revive_vm'
      post 'stop_archiving'
    end
  end

  scope 'slack' do
    get 'new' => 'slack#new', as: :new_slack
    get 'auth' => 'slack#update', as: :update_slack
  end

  # https://github.com/plataformatec/devise#configuring-routes
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
