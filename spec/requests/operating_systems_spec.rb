# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OperatingSystems', type: :request do
  describe 'GET /operating_systems as admin' do
    before do
      sign_in FactoryBot.create :admin
    end

    it 'works! (now write some real specs)' do
      get operating_systems_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /operating_systems as user' do
    before do
      sign_in FactoryBot.create :user
    end

    it 'does not work! (now write some real specs)' do
      get operating_systems_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /operating_systems as employee' do
    before do
      sign_in FactoryBot.create :employee
    end

    it 'does not work! (now write some real specs)' do
      get operating_systems_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
