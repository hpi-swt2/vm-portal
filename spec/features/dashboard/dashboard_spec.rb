# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

describe 'Dashboard', type: :feature do
  let(:user) { FactoryBot.create(:puppet_admin) }

  before do
    sign_in(user)
  end

  it 'does render notifications for a user' do
    visit(:dashboard)
    expect(page).to(have_text('Notifications'))
  end

  it 'does render a list of servers for a signed user' do
    skip('user is not yet connected to his hosts')
    visit(:dashboard)
    expect(page).to(have_text('Hosts'))
  end

  context 'with notifications' do
    before do
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
