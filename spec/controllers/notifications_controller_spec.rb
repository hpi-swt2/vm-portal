# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { FactoryBot.create :user }
  let(:valid_attributes) do
    {
      title: 'title',
      message: 'message',
      link: 'https://www.google.com',
      user: user
    }
  end

  # use let! instead of let otherwise the value will be lazily-instantiated
  let!(:notification) { Notification.create!(valid_attributes) }

  before do
    sign_in user
  end

  describe 'DELETE #destroy' do
    it 'destroys the notification' do
      expect do
        delete :destroy, params: { id: notification.to_param }
      end.to change(Notification, :count).by(-1)
    end
  end

  describe 'POST #destroy_and_redirect' do
    it 'destroys the notification' do
      expect do
        delete :destroy_and_redirect, params: { id: notification.to_param }
      end.to change(Notification, :count).by(-1)
    end

    it 'redirects to the notification link' do
      link = notification.link
      delete :destroy_and_redirect, params: { id: notification.to_param }
      expect(response).to redirect_to(link)
    end

    it 'redirects back if no link is provided' do
      notification.update!(link: '')
      redirect_url = 'https://www.google.com/'
      from redirect_url
      delete :destroy_and_redirect, params: { id: notification.to_param }
      expect(response).to redirect_to(redirect_url)
    end
  end
end
