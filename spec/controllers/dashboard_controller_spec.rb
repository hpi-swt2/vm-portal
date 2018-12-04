# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index"' do
    context 'when logged in' do
      it 'returns http success' do
        pending('simulate login')
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
