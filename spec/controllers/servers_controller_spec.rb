# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServersController, type: :controller do
  let(:valid_attributes) do
    {
      name: 'SpecServer',
      cpu_cores: 4,
      ram_gb: 1024,
      storage_gb: 4096,
      mac_address: 'C0:FF:EE:C4:11:42',
      fqdn: 'arrrr.speck.de',
      ipv4_address: '8.8.8.8',
      ipv6_address: '::1',
      installed_software: ['SpeckTester']
    }
  end

  let(:invalid_attributes) do
    {
      name: 'SpecServer',
      cpu_cores: '',
      ram_gb: 1024,
      storage_gb: 4096,
      mac_address: 'EE:C4:11:42',
      fqdn: 'arrrr.speck.de',
      ipv4_address: 'c8.a8.d8.b8',
      ipv6_address: 42,
      installed_software: ['SpeckTester']
    }
  end

  let(:valid_session) { {} }

  # Authenticate an user
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
        expect { post :create, params: { server: valid_attributes }, session: valid_session }.to change(Server, :count).by(1)
      end

      it 'redirects to the created server' do
        post :create, params: { server: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Server.last)
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
      let(:new_attributes) do
        {
          name: 'SpeckServer',
          cpu_cores: 2,
          ram_gb: 1024,
          storage_gb: 4096,
          mac_address: 'C0:FF:EE:C4:11:42',
          fqdn: 'arrrr.speck.de',
          ipv4_address: '8.8.8.8',
          ipv6_address: '::1',
          installed_software: ['SpeckTester']
        }
      end

      it 'updates the requested server' do
        server = Server.create! valid_attributes
        put :update, params: { id: server.to_param, server: new_attributes }, session: valid_session
        server.reload
        expect(server.name).to eq('SpeckServer')
      end

      it 'redirects to the server' do
        server = Server.create! valid_attributes
        put :update, params: { id: server.to_param, server: valid_attributes }, session: valid_session
        expect(response).to redirect_to(server)
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
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
