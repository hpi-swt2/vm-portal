# frozen_string_literal: true

require 'rails_helper'

describe 'devise/registrations/new.html.erb', type: :feature do
  before do
    visit new_user_registration_path
  end

  it 'has input fields for first name and list name' do
    expect(page).to have_field 'user[user_profile_attributes][first_name]'
    expect(page).to have_field 'user[user_profile_attributes][last_name]'
  end

  it 'creates a user with its profile data' do
    page.fill_in 'user[user_profile_attributes][first_name]', with: 'Max'
    page.fill_in 'user[user_profile_attributes][last_name]', with: 'Mustermann'

    page.fill_in 'user[email]', with: 'max@mustermann.com'
    page.fill_in 'user[password]', with: '123456'
    page.fill_in 'user[password_confirmation]', with: '123456'

    page.find('input[type=submit]').click

    user = User.find_by email: 'max@mustermann.com'

    expect(user.user_profile.first_name).to eq 'Max'
    expect(user.user_profile.last_name).to eq 'Mustermann'
  end
end
