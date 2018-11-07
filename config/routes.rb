# frozen_string_literal: true

Rails.application.routes.draw do
  get 'vm/index'
  get 'vm/show'
  get 'vm/update'
  get 'vm/delete'
  get 'vm/create'
  get 'vm/new'
  devise_for :users, path: 'users'
  resources :vm
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
