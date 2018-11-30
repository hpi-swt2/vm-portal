# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Requests', type: :request do
  # Authenticate an user
  before do
    user = FactoryBot.create :user
    sign_in user
  end

  describe 'GET /requests' do
    it 'works! (now write some real specs)' do
      # get requests_path
      # expect(response).to have_http_status(200)
    end
  end
end
