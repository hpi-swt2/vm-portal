# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: 'landing#index'
  get '/dashboard' => 'dashboard#index'
  get '/host/:id' => 'vm#show_host', constraints: { id: /.*/ }

  devise_for :users, path: 'users'
  resources :vm
end
