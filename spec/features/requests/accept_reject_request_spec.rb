# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :feature do
  context 'when request status is pending' do
    let(:request) { FactoryBot.create :request }

    it 'has accept button' do
      visit request_path(request)

      click_button('Accept')
      request.reload
      expect(request.status).to eq('accepted')
    end

    it 'has reject button' do
      visit request_path(request)

      click_button('Reject')
      request.reload
      expect(request.status).to eq('rejected')
    end

    it 'has rejection_information input field' do
      visit request_path(request)

      page.fill_in 'request[rejection_information]', with: 'Info'
      click_button('Reject')
      request.reload
      expect(request.rejection_information).to eq('Info')
    end
  end

  context 'when request is rejected' do
    let(:rejected_request) { FactoryBot.create :rejected_request }

    it 'Has rejection Information field' do
      visit request_path(rejected_request)

      expect(page).to have_text(rejected_request.rejection_information)
    end
  end
end
