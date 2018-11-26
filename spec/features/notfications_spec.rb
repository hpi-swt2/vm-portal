# frozen_string_literal: true

require 'rails_helper'

describe 'Index page', type: :feature do

  it 'should have notifications' do
    notifcation = FactoryBot.create(:notification)
    visit notifications_path

    expect(page).to have_text(notifcation.title)
    expect(page).to have_text(notifcation.message)
  end

  it 'should mark notification as read' do
    notifcation = FactoryBot.create(:notification)
    visit mark_as_read_notification_path(notifcation)

    expect(notifcation.reload.read).to be(true)
  end
end