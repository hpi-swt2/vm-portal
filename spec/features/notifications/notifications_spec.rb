# frozen_string_literal: true

require 'rails_helper'

describe 'Index page', type: :feature do
  context 'with notifications' do
    before do
      user = create(:user)
      login_as(user, scope: :user)
      @notification = FactoryBot.create(:notification, user: user)
    end

    it 'has notifications with title' do
      visit notifications_path

      expect(page).to have_text(@notification.title)
    end

    it 'has notifications with messages' do
      visit notifications_path

      expect(page).to have_text(@notification.message)
    end

    it 'marks notification as read' do
      visit mark_as_read_notification_path(@notification)

      expect(@notification.reload.read).to be(true)
    end
  end

  context 'without notifications' do
    before do
      user = create(:user)
      login_as(user, scope: :user)
    end

    it 'informs about no notifications' do
      visit notifications_path

      expect(page).to have_text('You don\'t have any notifications at the moment.')
    end
  end
end

describe 'Nav header', type: :feature do
  before do
    user = create(:user)
    login_as(user, scope: :user)
    @notification = FactoryBot.create(:notification, user: user)
  end

  it 'has a link to notifications' do
    visit requests_path

    click_link 'header-notification-bell'
    expect(page).to have_text(@notification.message)
  end
end

describe 'Notification sending', type: :feature do
  let(:user) do
    user = create(:user)
    login_as(user, scope: :user)
    user
  end

  it 'notifies slack' do
    allow(user).to receive(:notify_slack)
    user.notify('Notification title', 'The notification message', '')
    expect(user).to have_received(:notify_slack)
  end

  it 'creates a notification object' do
    notification_count = Notification.all.length
    user.notify('Notification title', 'The notification message', '')
    expect(Notification.all.length).to equal(notification_count + 1)
  end
end
