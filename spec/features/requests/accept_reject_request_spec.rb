# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accepting and rejecting requests', type: :feature do
  let (:request) { FactoryBot.create :request}

  before do
    sign_in FactoryBot.create :admin
    visit request_path(request)
  end

  context 'when request status is pending' do
    context 'and will be accepted' do
      before do
        click_button('acceptButton')
      end

      it 'has an accepted status' do
        request.reload
        expect(request.status).to eq('accepted')
      end

      it 'routes to the new_vm_path' do
        expect(page).to have_current_path(new_vm_path(request: request))
      end

      it 'has automatically filled fields' do
        find('input[name="name"][value*="MyVM"]')
        find('input[name="cpu"][value*="2"]')
        find('input[name="ram"][value*="1000"]')
        find('input[name="capacity"][value*="2000"]')
      end
    end

    context 'and will be rejected' do
      it 'has a working reject button' do
        click_button('rejectButton')
        request.reload
        expect(request.status).to eq('rejected')
      end

      context 'with a filled in rejection information field' do
        before do
          page.fill_in 'request[rejection_information]', with: 'Info'
          click_button('rejectButton')
        end

        it 'saves the rejection information' do
          request.reload
          expect(request.rejection_information).to eq('Info')
        end

        it 'shows rejection information' do
          expect(page).to have_text('Info')
        end
      end
    end
  end
end
