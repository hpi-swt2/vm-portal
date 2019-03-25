# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:notification) { FactoryBot.create :notification }
  let(:user) { notification.user }

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

  describe 'GET #mark_as_read_and_redirect' do
    it 'marks the notification as read' do
      expect {
        get :mark_as_read_and_redirect, params: { id: notification.to_param }
      }.to change{notification.reload.read}.from(false).to(true)
    end

    it 'redirects to the notification link' do
      get :mark_as_read_and_redirect, params: { id: notification.to_param }
      expect(response).to redirect_to(notification.link)
    end

    it 'redirects back if no link is provided' do
      notification.update!(link: '')
      redirect_url = 'https://www.google.com/'
      from redirect_url
      get :mark_as_read_and_redirect, params: { id: notification.to_param }
      expect(response).to redirect_to(redirect_url)
    end
  end
end
