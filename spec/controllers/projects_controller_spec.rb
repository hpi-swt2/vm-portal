# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:user) { FactoryBot.create :admin }
  let(:project) { FactoryBot.create :project, responsible_users: [user] }

  let(:current_user) { user }

  before do
    sign_in current_user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: project }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: project }
      expect(response).to have_http_status(:success)
    end
  end

  context 'when the current_user is not responsible for the project' do
    let(:current_user) { FactoryBot.create :user }

    before do
      get :edit, params: { id: project }
    end

    it 'returns http redirect' do
      expect(response).to have_http_status(:redirect)
    end

    it 'redirects to the dashboard' do
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
