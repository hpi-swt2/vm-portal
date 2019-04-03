# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accepting and rejecting requests', type: :feature do
  let(:request) { FactoryBot.create :request }
  let(:admin) { FactoryBot.create :admin }

  before do
    sign_in admin
    visit request_path(request)
  end

  context 'when request status is pending' do
    context 'clicking the accept button' do
      before do
        click_button('acceptButton')
      end

      it 'has an accepted status' do
        request.reload
        expect(request.status).to eq('accepted')
      end

      it 'redirects to VMs config page' do
        expect(page).to have_current_path(edit_config_path(request.name))
      end
    end

    context 'clicking the reject button' do
      it 'has a working reject button' do
        click_button('rejectButton')
        request.reload
        expect(request.status).to eq('rejected')
      end

      context 'with a filled in rejection information field' do
        before do
          @rejection_info = 'a reason why the VM request was rejected'
          page.fill_in 'request[rejection_information]', with: @rejection_info
          click_button('rejectButton')
        end

        it 'saves the rejection information' do
          request.reload
          expect(request.rejection_information).to eq(@rejection_info)
        end

        it 'redirects to the requests path' do
          expect(page).to have_current_path(requests_path)
        end
      end
    end

    context 'and the request was created by an admin' do
      let(:request) { FactoryBot.create :request, user: admin }

      context 'clicking the accept button' do
        before do
          click_button('acceptButton')
          request.reload
        end

        it 'change the requests state' do
          expect(request.status).to eq 'accepted'
        end
      end

      context 'clicking the reject button' do
        before do
          click_button('rejectButton')
          request.reload
        end

        it 'change the requests state' do
          expect(request.status).to eq 'rejected'
        end
      end
    end
  end
end
