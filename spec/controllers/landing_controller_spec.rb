# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingController, type: :controller do
  describe 'GET #index"' do

    context 'when logged in' do
      it 'redirects to dashboard' do
        pending('simulate login')
        get(:index)
        response.should redirect_to('/dashboard')
      end
    end

    context 'when logged out' do
      it 'redirects to login page' do
        get(:index)
        response.should redirect_to('/users/sign_in')
      end
    end
  end
end
