# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index"' do
    context 'when logged in' do
      before do
        user = FactoryBot.create :user
        sign_in(user)
      end

      it 'returns http success' do
        skip 'Find solution for timeout when loading dashboard'
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged out' do
      it 'redirects to the login page' do
        get(:index)
        response.should redirect_to('/users/sign_in')
      end
    end
  end
end
