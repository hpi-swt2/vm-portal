# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }

  describe 'GET #index' do
    context 'when the user is an admin' do
      before do
        sign_in admin
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'when the user is not an admin' do
    before do
      sign_in user
    end

    it 'redirects to the dashboard' do
      get :index
      expect(response).to redirect_to(dashboard_path)
    end

    it 'returns http success for normal users in development environment' do
      allow(Rails.env).to receive(:development?).and_return(true)
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
