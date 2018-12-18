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

  context 'with notifications' do
    before do
      user = FactoryBot.create(:user)
      sign_in(user)
      @notifications = FactoryBot.create_list(:notification, 4, user: user)
    end

    it 'has notifications with title' do
      visit dashboard_path
      expect(page).to have_text(@notifications.first.title)
    end

    it 'has notifications with messages' do
      visit dashboard_path
      expect(page).to have_text(@notifications.first.message)
    end

    it 'does not redirect after marking notification as read' do
      visit dashboard_path
      all(:css, '.check.icon-link').first.click
      expect(current_path).to eql(dashboard_path)
    end

    it 'does not redirect after deleting notification' do
      visit dashboard_path
      all(:css, '.delete.icon-link').first.click
      expect(current_path).to eql(dashboard_path)
    end

    it 'does not display more than 3 notifications' do
      visit dashboard_path
      expect(page).to have_selector('.check.icon-link', count: 3)
    end
  end

  context 'without notifications' do
    it 'informs about no notifications' do
      visit dashboard_path
      expect(page).to have_text('You don\'t have any notifications at the moment.')
    end
  end
end
