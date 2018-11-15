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
end
