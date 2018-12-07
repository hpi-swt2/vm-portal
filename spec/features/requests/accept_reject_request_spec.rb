# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :feature do
  # Authenticate an user
  before do
    sign_in FactoryBot.create :user, role: :wimi
  end

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

  context 'when request is accepted' do
    let(:request) { FactoryBot.create :request }

    it 'has an accepted status' do
      visit request_path(request)

      click_button('Accept')
      request.reload
      expect(request.status).to eq('accepted')
    end

    it 'routes to the new_vm_path' do
      visit request_path(request)

      click_button('Accept')
      expect(current_path).to eq(new_vm_path)
    end

    it 'has automatically filled fields' do
      visit request_path(request)

      click_button('Accept')
      find('input[name="name"][value*="MyVM"]')
      find('input[name="cpu"][value*="2"]')
      find('input[name="ram"][value*="1000"]')
      find('input[name="capacity"][value*="2000"]')
    end

    it 'the request information page has an accepted status' do
      visit request_path(request)

      click_button('Accept')
      visit request_path(request)

      expect(page).to have_text('accepted')
    end
  end
end
