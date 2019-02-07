# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Servers', type: :request do
  describe 'GET /servers as admin' do
    before do
      sign_in FactoryBot.create :admin
    end

    it 'works! (now write some real specs)' do
      get servers_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /servers as user' do
    before do
      sign_in FactoryBot.create :user
    end

    it 'does not work! (now write some real specs)' do
      get servers_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /servers as employee' do
    before do
      sign_in FactoryBot.create :employee
    end

    it 'works! (now write some real specs)' do
      get servers_path
      expect(response).to have_http_status(200)
    end
  end
end
