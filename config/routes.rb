# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  # You can specify what Rails should route '/' to with the root method
  # https://guides.rubyonrails.org/routing.html#using-root
  root 'landing#index'

  # '/dashboard'
  get '/dashboard' => 'dashboard#index', as: :dashboard
  # '/projects/...'
  resources :projects, only: %i[index show new edit create update]
  # '/app_settings/...'
  resources :app_settings, only: %i[update edit]
  # '/hosts/...', '/servers/...'
  resources :hosts, :servers
  get '/hosts/:id' => 'hosts#show', constraints: { id: /.*/ }

  # '/notifications/...'
  resources :notifications, only: %i[index new create destroy] do
    member do
      get :mark_as_read
      delete :destroy_and_redirect
    end
    get :has_any, on: :collection, to: 'notifications#any?'
  end

  # '/slack/...'
  scope 'slack' do
    get 'new' => 'slack#new', as: :new_slack
    get 'auth' => 'slack#update', as: :update_slack
  end

  # https://guides.rubyonrails.org/routing.html#prefixing-the-named-route-helpers
  # '/vms/...'
  scope 'vms' do
    # '/vms/request_templates/...'
    resources :request_templates, except: :show
    # '/vms/requests/operating_systems/...'
    # Order matters here, as routes are matched from top to bottom
    # If 'resources :requests' is first, it will attempt to match that
    resources :operating_systems, path: 'requests/operating_systems', except: :show
    # '/vms/requests/...'
    resources :requests do
      post :push_to_git, on: :member
      patch :reject, on: :collection
    end
    # '/vms/configs/:id'
    scope 'configs' do
      get ':id' => 'vms#edit_config', constraints: { id: /.*/ }, as: :edit_config
      patch ':id' => 'vms#update_config', constraints: { id: /.*/ }, as: :update_config
    end
    # '/vms/vm'
    # move all vm actions under /vms/vm because a VM named requests might otherwise lead to issues!
    resources :vms, except: %i[new create], path: 'vm', constraints: { id: /.*/ } do
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
  end

  # '/users/...'
  # https://github.com/plataformatec/devise#configuring-routes
  devise_for :users, path: 'users',
    controllers: {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  resources :users do
    patch :update_role, on: :member
  end
end
