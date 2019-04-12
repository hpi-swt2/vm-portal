# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServersController, type: :controller do
  let(:valid_attributes) do
    employee = FactoryBot.create(:employee)
    FactoryBot.attributes_for(:server, responsible_id: employee.id)
  end

  let(:invalid_attributes) do
    { cpu_cores: 'twelve-hundred', mac_address: 1234 }
  end

  let(:valid_session) { {} }

  # Authenticate an admin
  before do
    sign_in FactoryBot.create :admin
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Server.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      server = Server.create! valid_attributes
      get :show, params: { id: server.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it 'returns 404 when id is not valid' do
      get :show, params: { id: 'invalid_id' }, session: valid_session
      expect(response.status).to eq(404)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      server = Server.create! valid_attributes
      get :edit, params: { id: server.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Server' do
        expect {
          post :create, params: { server: valid_attributes }, session: valid_session
        }.to change(Server, :count).by(1)
      end

      it 'redirects to the created server' do
        post :create, params: { server: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Server.last)
      end

      it 'creates a new Server without saving empty software fields' do
        valid_attributes.update(installed_software: ['software', '', ''])
        post :create, params: { server: valid_attributes }, session: valid_session
        expect(Server.last.installed_software).to eq(['software'])
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { server: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested server' do
        server = FactoryBot.create(:server, name: 'Original')
        valid_attributes.update(name: 'Changed')
        expect{
          put :update, params: { id: server.to_param, server: valid_attributes }, session: valid_session
        }.to change{ server.reload.name }.from(server.name).to(valid_attributes[:name])
      end

      it 'redirects to the server' do
        server = Server.create! valid_attributes
        put :update, params: { id: server.to_param, server: valid_attributes }, session: valid_session
        expect(response).to redirect_to(server)
      end

      it 'updates the requested server without saving empty software fields' do
        server = FactoryBot.create(:server, installed_software: [])
        valid_attributes.update(installed_software: ['software', '', ''])
        expect do
          put :update, params: { id: server.to_param, server: valid_attributes }, session: valid_session
        end.to change { server.reload.installed_software }.from(server.installed_software).to(['software'])
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        server = Server.create! valid_attributes
        put :update, params: { id: server.to_param, server: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested server' do
      server = Server.create! valid_attributes
      expect { delete :destroy, params: { id: server.to_param }, session: valid_session }.to change(Server, :count).by(-1)
    end

    it 'redirects to the servers list' do
      server = Server.create! valid_attributes
      delete :destroy, params: { id: server.to_param }, session: valid_session
      expect(response).to redirect_to(servers_url)
    end
  end
end

RSpec.describe ServersController, type: :controller do
  let(:valid_session) { {} }

  # Authenticate an user
  before do
    sign_in FactoryBot.create :user
    get :index
  end

  describe 'GET #index if user is logged in' do
    it 'returns http redirect' do
      expect(response).to have_http_status(:redirect)
    end
  end
end
