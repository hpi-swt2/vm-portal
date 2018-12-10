# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

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
