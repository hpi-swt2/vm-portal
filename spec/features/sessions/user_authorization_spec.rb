# frozen_string_literal: true

require 'rails_helper'

describe 'Authorization', type: :feature do
  context 'when user is not logged in' do
    it 'redirects the user' do
      visit vms_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'shows an error message' do
      visit vms_path
      expect(page).to have_text 'You need to sign in before continuing.'
    end
  end

  context 'when user is logged in' do
    it 'lets the user stay on the index page' do
      sign_in FactoryBot.create :user
      visit vms_path
      expect(page).to have_current_path(vms_path)
    end
  end
end
