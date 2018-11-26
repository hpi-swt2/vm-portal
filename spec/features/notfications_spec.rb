# frozen_string_literal: true

require 'rails_helper'

describe 'Index page', type: :feature do
  it 'has notifications with title' do
    notifcation = FactoryBot.create(:notification)
    visit notifications_path

    expect(page).to have_text(notifcation.title)
  end

  it 'has notifications with messages' do
    notifcation = FactoryBot.create(:notification)
    visit notifications_path

    expect(page).to have_text(notifcation.message)
  end

  it 'marks notification as read' do
    notifcation = FactoryBot.create(:notification)
    visit mark_as_read_notification_path(notifcation)

    expect(notifcation.reload.read).to be(true)
  end
end
