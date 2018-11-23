# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: redirect('/users/sign_in')

  get 'slack' => 'slack_spike#index'
  get 'slack/auth' => 'slack_spike#auth'

  devise_for :users, path: 'users'
  resources :vm

  root 'landing#index'
end
