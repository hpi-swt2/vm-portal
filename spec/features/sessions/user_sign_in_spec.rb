require 'rails_helper'

describe 'devise/sessions/new.html.erb', type: :feature do

  before :each do
    visit new_user_session_path
  end

  it 'should have a username field' do
    expect(page).to have_field'user[email]'
  end

  it 'should have a user password field' do
    expect(page).to have_field 'user[password]'
  end

  it 'should have a log in button' do
    expect(page).to have_selector 'input[type=submit]'
  end

  it 'should have an oauth button' do
    expect(page).to have_button 'Sign in using OAuth'
  end
end