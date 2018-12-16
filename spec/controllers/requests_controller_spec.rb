# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe RequestsController, type: :controller do
  # Authenticate an user
  login_wimi

  # This should return the minimal set of attributes required to create a valid
  # Request. As you add validations to Request, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      name: 'MyVM',
      cpu_cores: 2,
      ram_mb: 1000,
      storage_mb: 2000,
      operating_system: 'MyOS',
      comment: 'Comment',
      status: 'pending'
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      cpu_cores: 2,
      ram_mb: 1000,
      storage_mb: -2000,
      operating_system: '',
      comment: 'Comment',
      status: 'pending'
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RequestsController. Be sure to keep this updated too.

  describe 'GET #index' do
    it 'returns a success response' do
      Request.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      request = Request.create! valid_attributes
      get :show, params: { id: request.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      request = Request.create! valid_attributes
      get :edit, params: { id: request.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Request' do
        expect do
          post :create, params: { request: valid_attributes }
        end.to change(Request, :count).by(1)
      end

      it 'redirects to the request overview if user is not an admin' do
        post :create, params: { request: valid_attributes }
        expect(response).to redirect_to(dashboard_url)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the "new" template)' do
        post :create, params: { request: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          name: 'MyNewVM',
          cpu_cores: 3,
          ram_mb: 2000,
          storage_mb: 3000,
          operating_system: 'MyNewOS',
          comment: 'newComment',
          status: 'pending'
        }
      end

      it 'updates the requested request' do
        request = Request.create! valid_attributes
        put :update, params: { id: request.to_param, request: new_attributes }
        request.reload
        expect(request.name).to eq('MyNewVM')
      end

      it 'redirects to the request' do
        request = Request.create! valid_attributes
        put :update, params: { id: request.to_param, request: valid_attributes }
        expect(response).to redirect_to(request)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the "edit" template)' do
        request = Request.create! valid_attributes
        put :update, params: { id: request.to_param, request: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested request' do
      request = Request.create! valid_attributes
      expect do
        delete :destroy, params: { id: request.to_param }
      end.to change(Request, :count).by(-1)
    end

    it 'redirects to the requests list' do
      request = Request.create! valid_attributes
      delete :destroy, params: { id: request.to_param }
      expect(response).to redirect_to(requests_url)
    end
  end
end
