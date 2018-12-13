# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  before do
    user = FactoryBot.create(:user)
    sign_in(user)
  end

  it 'does render a list of all available vms for a signed in user' do
    skip('Find solution for timeout when loading dashboard')
    visit(:dashboard)
    expect(page).to(have_text('VMs'))
    skip('user is not yet connected to his vms')
  end

  it 'does render an empty list if a user does not have access to a vm' do
    skip('user is not yet connected to his vms')
  end

  it 'does render a selection of details per vm' do
    skip('user is not yet connected to his vms')
  end

  it 'does render notifications for a user' do
    skip 'Find solution for timeout when loading dashboard'
    visit(:dashboard)
    expect(page).to(have_text('Notifications'))
    skip('user is not yet connected to his notifications')
  end

  it 'does render a list of servers for a signed user' do
    skip 'Find solution for timeout when loading dashboard'
    visit(:dashboard)
    expect(page).to(have_text('Hosts'))
    skip('user is not yet connected to his hosts')
  end
end
