# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:valid_attributes) do
    {
      title: 'title',
      message: 'message',
      link: 'https://www.google.com',
      user: FactoryBot.create(:user)
    }
  end

  describe 'DELETE #destroy' do
    it 'destroys the notification' do
      notification = Notification.create!(valid_attributes)
      expect do
        delete :destroy, params: { id: notification.to_param }
      end.to change(Notification, :count).by(-1)
    end
  end

  describe 'POST #destroy_and_redirect' do
    it 'destroys the notification' do
      notification = Notification.create!(valid_attributes)
      expect do
        post :destroy_and_redirect, params: { id: notification.to_param }
      end.to change(Notification, :count).by(-1)
    end
  end
end
