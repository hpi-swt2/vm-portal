# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: redirect('/users/sign_in')

  get '/host/:id' => 'vm#show_host', constraints: { id: /.*/ }

  devise_for :users, path: 'users'
  get 'users/:id/profile' => 'user#show', as: 'user'
  get 'users/' => 'user#index'

  resources :vm

  root 'landing#index'
end
