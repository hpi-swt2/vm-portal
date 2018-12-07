# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :request_templates, path: '/vms/request_templates'
  resources :requests, path: '/vms/requests'

  root to: redirect('/users/sign_in')

  get '/servers/:id' => 'servers#show', constraints: { id: /.*/ }

  devise_for :users, controllers: { registrations: 'users/registrations' }, path: 'users'
  resources :vms, :servers
  resources :users, only: %i[show index]

  root 'landing#index'
end
