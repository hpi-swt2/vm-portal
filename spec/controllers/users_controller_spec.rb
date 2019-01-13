# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }

  describe 'GET #index' do
    it 'returns http success' do
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
      get :show, params: { id: user }
      expect(response).to have_http_status(:success)
    end
  end
end
