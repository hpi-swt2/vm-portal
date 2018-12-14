# frozen_string_literal: true

require 'rails_helper'

describe 'Sign In Page', type: :feature do
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

  it 'has an open id connect button' do
    expect(page).to have_link 'Sign in with HPI OpenID Connect'
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

  context 'with HPI OpenID Connect' do
    context 'with valid credentials' do
      before do
        OmniAuth.config.mock_auth[:hpi] = OmniAuth::AuthHash.new(
          {
              provider: 'hpi',
              uid: '123545',
              info: {
                  first_name: 'Max',
                  last_name: 'Mustermann',
                  email: 'max.mustermann@student.hpi.de'
              }
          })
      end

      it 'performs a successful login' do
        page.click_link 'Sign in with HPI OpenID Connect'
        expect(page).to have_text('Logout')
      end
    end

    context 'with invalid credentials' do
      before do
        OmniAuth.config.mock_auth[:hpi] = :invalid_credentials
      end

      it 'does not perform a successful login' do
        page.click_link 'Sign in with HPI OpenID Connect'
        expect(page).to_not have_text('Logout')
        expect(page).to have_text('Login')
      end
    end
  end
end
