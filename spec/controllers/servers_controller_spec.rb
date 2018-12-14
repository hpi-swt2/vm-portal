require 'rails_helper'

RSpec.describe ServersController, type: :controller do

  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }

  # Authenticate an user
  before do
    sign_in FactoryBot.create :user
  end

  describe "GET #index" do
    it "returns a success response" do
      Server.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      server = Server.create! valid_attributes
      get :show, params: {id: server.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      server = Server.create! valid_attributes
      get :edit, params: {id: server.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Server" do
        expect {
          post :create, params: {server: valid_attributes}, session: valid_session
        }.to change(Server, :count).by(1)
      end

      it "redirects to the created server" do
        post :create, params: {server: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Server.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: {server: invalid_attributes}, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested server" do
        server = Server.create! valid_attributes
        put :update, params: {id: server.to_param, server: new_attributes}, session: valid_session
        server.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the server" do
        server = Server.create! valid_attributes
        put :update, params: {id: server.to_param, server: valid_attributes}, session: valid_session
        expect(response).to redirect_to(server)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        server = Server.create! valid_attributes
        put :update, params: {id: server.to_param, server: invalid_attributes}, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested server" do
      server = Server.create! valid_attributes
      expect {
        delete :destroy, params: {id: server.to_param}, session: valid_session
      }.to change(Server, :count).by(-1)
    end

    it "redirects to the servers list" do
      server = Server.create! valid_attributes
      delete :destroy, params: {id: server.to_param}, session: valid_session
      expect(response).to redirect_to(servers_url)
    end
  end

end
