
require 'rails_helper'

RSpec.describe 'notifications/_list.html.erb', type: :view do

  before do
    assign :notifications, notifications
    render
  end

  describe 'list of notifications' do

    let(:read_notification) { FactoryBot.create :read_notification }

    let(:unread_notification) { FactoryBot.create :notification }

    let(:notifications) do
      [FactoryBot.create(:error_notification), read_notification, unread_notification]
    end

    it 'renders the title of each notification' do
      notifications.each do |notification|
        expect(rendered).to have_text(notification.title)
      end
    end

    it 'renders the message of each notification' do
      notifications.each do |notification|
        expect(rendered).to have_text(notification.message)
      end
    end
  end

  context 'when the notification is an error' do
    let(:notifications) do
      [FactoryBot.create(:error_notification)]
    end

    it 'renders an error icon' do
      expect(rendered).to have_css_class 'fa-exclamation-triangle'
    end
  end

  context 'when the nofification is normal' do
    let(:notifications) do
      [FactoryBot.create(:notification)]
    end

    it 'does not render an error icon' do
      expect(rendered).not_to have_css_class 'fa-exclamation-triangle'
    end
  end

  describe 'notification count' do
    # we can declare :count later because let works using lazy initialization
    # pro tip: if you want to use a non-lazy let, you can use let!
    let(:notifications) { [FactoryBot.create(:notification, count: count)] }

    context 'when the notification occurred multiple times' do
      let(:count) { 3 }

      it 'displays the count' do
        expect(rendered).to have_text(count.to_s + ' times')
      end
    end

    context 'when the notification occured once' do
      let(:count) { 1 }

      it 'does not display the count' do
        expect(rendered).not_to have_text(count.to_s + ' times')
      end
    end
  end
end
