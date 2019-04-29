# frozen_string_literal: true

require 'rails_helper'

describe 'Notifications index page', type: :feature do
  before do
    @user = create(:user)
    login_as(@user)
  end

  context 'with notifications' do
    before do
      @notification = FactoryBot.create(:notification, user: @user)
      visit notifications_path
    end
    
    it 'displays title' do
      expect(page).to have_text(@notification.title)
    end
    
    it 'displays messages' do
      expect(page).to have_text(@notification.message)
    end
    
    it 'allows marking notification as read' do
      expect{
        find("a[href='#{mark_as_read_and_redirect_notification_path(@notification)}']").click
      }.to change{@notification.reload.read}.from(false).to(true)
    end
    
    it 'redirects to notification links within the application' do
      @notification.update(link: user_path(@user))
      visit notifications_path
      find("a[href='#{mark_as_read_and_redirect_notification_path(@notification)}']").click
      expect(page).to have_current_path(@notification.link)
    end

    it 'deals with empty notification links' do
      @notification.update(link: nil)
      visit notifications_path
      find("a[href='#{mark_as_read_and_redirect_notification_path(@notification)}']").click
      expect(page).to have_current_path(notifications_path)
    end
  end

  context 'without notifications' do
    it 'informs about no notifications' do
      visit notifications_path
      expect(page).to have_css('#no-notifications', count: 1)
    end
  end
end

describe 'Notification sending', type: :feature do
  before do
    @user = create(:user)
    login_as(@user)
    @attrs = FactoryBot.attributes_for(:notification)
  end

  it 'notifies slack' do
    allow(@user).to receive(:notify_slack)
    @user.notify(@attrs['title'], @attrs['message'], @attrs['link'])
    expect(@user).to have_received(:notify_slack)
  end

  it 'creates a notification object when calling notify' do
    expect{
      @user.notify(@attrs['title'], @attrs['message'], @attrs['link'])
    }.to change{Notification.count}.by(1)
  end
end
