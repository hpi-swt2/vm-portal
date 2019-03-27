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

  describe 'PUT #update' do
    let(:other_user) { FactoryBot.create :employee }

    before do
      put :update, params: { id: project.id, project: new_attributes }
      project.reload
    end

    context 'with valid params' do
      let(:new_attributes) do
        {
          name: 'Super new Project',
          description: 'Super Awesome Description',
          responsible_users_ids: [other_user.id]
        }
      end

      it 'updates the requested project name' do
        expect(project.name).to eq(new_attributes[:name])
      end

      it 'updates the requested project description' do
        expect(project.description).to eq(new_attributes[:description])
      end

      it 'updates the requested project responsible user' do
        expect(project.responsible_users.map(&:id)).to eq(new_attributes[:responsible_users_ids])
      end

      it 'redirects to the project' do
        expect(response).to redirect_to(project)
      end
    end

    context 'with invalid params' do
      let(:new_attributes) do
        {
          name: '',
          description: 'Super Awesome Description',
          responsible_users_ids: [other_user.id]
        }
      end

      it 'does not update the project' do
        expect(project.name).not_to be(new_attributes[:name])
      end
    end
  end
end
