# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }

  describe 'GET #index' do
    it 'redirects normal users' do
      sign_in user
      get :index
      expect(response).to have_http_status(302) # redirect
    end

    it 'returns http success for normal users in development environment' do
      sign_in user
      allow(Rails.env).to receive(:development?).and_return(true)
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'returns http success for admins' do
      sign_in admin
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      sign_in admin
      get :show, params: { id: user }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      sign_in user
      get :edit, params: { id: user }
      expect(response).to have_http_status(:success)
    end
  end
end
