# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: 'users'
  resources :vm
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
