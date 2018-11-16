# frozen_string_literal: true

require 'rails_helper'

describe 'devise/sessions/new.html.erb', type: :feature do
  before do
    visit new_user_session_path
  end

  it 'has a username field' do
    expect(page).to have_field 'user[email]'
  end

  it 'has a user password field' do
    expect(page).to have_field 'user[password]'
  end

  it 'has a log in button' do
    expect(page).to have_selector 'input[type=submit]'
  end

  it 'has an oauth button' do
    expect(page).to have_button 'Sign in using OAuth'
  end

  it 'shows an error message if email is not found' do
    page.fill_in 'user[email]', with: 'login@email.com'
    page.fill_in 'user[password]', with: 'secret_password'
    page.find('input[type=submit]').click
    expect(page).to have_text 'This user account does not exist.'
  end

  it 'shows an error message if password is incorrect' do
    user = FactoryBot.create :user
    page.fill_in 'user[email]', with: user.email
    page.fill_in 'user[password]', with: 'secret'
    page.find('input[type=submit]').click
    expect(page).to have_text 'Invalid password.'
  end
end
