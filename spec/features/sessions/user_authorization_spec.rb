# frozen_string_literal: true

require 'rails_helper'

describe 'Authorization', type: :feature do
  it 'redirects the user if not logged in' do
    visit vm_index_path
    expect(page).to have_current_path(new_user_session_path)
  end

  it 'shows an error message if unauthorized access' do
    visit vm_index_path
    expect(page).to have_text 'You need to sign in before continuing.'
  end

  it 'allows usage if logged in' do
    user = FactoryBot.create :user
    sign_in(user)
    visit vm_index_path
    expect(page).to have_current_path(vm_index_path)
  end
end
