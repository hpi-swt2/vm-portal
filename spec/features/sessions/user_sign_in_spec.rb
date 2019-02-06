# frozen_string_literal: true

require 'rails_helper'

describe 'Sign In Page', type: :feature do
  before do
    visit new_user_session_path
    @user = FactoryBot.create :user
  end

  it 'has an open id connect button' do
    expect(page).to have_link 'Sign in with HPI OpenID Connect'
  end

  context 'with HPI OpenID Connect' do
    context 'with valid credentials' do
      before do
        OmniAuth.config.mock_auth[:hpi] = OmniAuth::AuthHash.new(
          provider: 'hpi',
          uid: '123545',
          info: {
            first_name: 'Max',
            last_name: 'Mustermann',
            email: 'max.mustermann@student.hpi.de'
          }
        )
      end

      context 'Successful login' do
        before do
          page.click_link 'Sign in with HPI OpenID Connect'
        end

        it 'Login button is now Logout' do
          expect(page).to have_text('Logout')
          expect(page).not_to have_text('Login')
        end

        it 'shows a Success Flash message after successful login' do
          expect(page).to have_text 'Successfully authenticated'
          expect(page).to have_css('.alert-success')
        end
      end
    end

    context 'with invalid credentials' do
      before do
        OmniAuth.config.mock_auth[:hpi] = :invalid_credentials
      end

      context 'unsuccessful login' do
        before do
          page.click_link 'Sign in with HPI OpenID Connect'
        end

        it 'Login button still there and no Logout' do
          expect(page).not_to have_text('Logout')
          expect(page).to have_text('Login')
        end

        it 'shows Danger Flash Message' do
          expect(page).to have_text('Could not authenticate')
          expect(page).to have_css('.alert-danger')
        end
      end
    end
  end
end
