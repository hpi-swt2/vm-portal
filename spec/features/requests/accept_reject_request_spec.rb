# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accepting and rejecting requests', type: :feature do
  # Authenticate an user
  before do
    sign_in FactoryBot.create :user, role: :wimi
  end

  context 'when request status is pending' do
    let(:request) { FactoryBot.create :request }

    before do
      visit request_path(request)
    end

    it 'has a working accept button' do
      click_button('Accept')
      request.reload
      expect(request.status).to eq('accepted')
    end

    it 'has a working reject button' do
      click_button('Reject')
      request.reload
      expect(request.status).to eq('rejected')
    end

    it 'has a working rejection_information input field' do
      page.fill_in 'request[rejection_information]', with: 'Info'
      click_button('Reject')
      request.reload
      expect(request.rejection_information).to eq('Info')
    end
  end

  context 'when request is rejected' do
    let(:rejected_request) { FactoryBot.create :rejected_request }

    it 'has a working rejection information field' do
      visit request_path(rejected_request)

      expect(page).to have_text(rejected_request.rejection_information)
    end
  end
end
