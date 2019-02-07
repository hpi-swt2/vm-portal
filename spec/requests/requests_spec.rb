# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Requests', type: :request do
  describe 'GET /requests' do
    before do
      user = FactoryBot.create :admin
      sign_in user
    end

    it 'works! (now write some real specs)' do
      get requests_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /requests as user' do
    before do
      sign_in FactoryBot.create :user
    end

    it 'does not work! (now write some real specs)' do
      get requests_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /requests as employee' do
    before do
      sign_in FactoryBot.create :employee
    end

    it 'works! (now write some real specs)' do
      get requests_path
      expect(response).to have_http_status(200)
    end
  end
end
