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
  let(:user) { FactoryBot.create :employee }
  let(:sudo_user) { FactoryBot.create :user }
  let(:sudo_user2) { FactoryBot.create :admin }

  # This should return the minimal set of attributes required to create a valid
  # Request. As you add validations to Request, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      name: 'myvm',
      cpu_cores: 2,
      ram_gb: 1,
      storage_gb: 2,
      operating_system: 'MyOS',
      description: 'Description',
      comment: 'Comment',
      status: 'pending',
      user: user,
      responsible_user_ids: [user.id],
      sudo_user_ids: ['', sudo_user.id.to_s, sudo_user2.id.to_s],
      user_ids: ['', user.id.to_s]
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      cpu_cores: 2,
      ram_gb: 1000,
      storage_gb: -2000,
      operating_system: '',
      description: '',
      comment: 'Comment',
      status: 'pending',
      user: user,
      sudo_user_ids: ['', sudo_user.id.to_s] # the first parameter is for some reason always empty
    }
  end

  #one of the attributes should be higher than the max resource of the host list
  let(:to_high_resource_attributes) do
    {
      name: 'myvm',
      cpu_cores: 1000000000000000,
      ram_gb: 1,
      storage_gb: 2,
      operating_system: 'MyOS',
      description: 'Description',
      comment: 'Comment',
      status: 'pending',
      user: user,
      responsible_user_ids: [user.id],
      sudo_user_ids: ['', sudo_user.id.to_s, sudo_user2.id.to_s]
    }
  end


  # Authenticate an user
  before do
    sign_in user
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

      it 'redirects to the request page index page' do
        post :create, params: { request: valid_attributes }
        expect(response).to redirect_to(requests_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a request if responible users are empty' do
        request_count = Request.all.size
        post :create, params: { request: valid_attributes.except(:responsible_user_ids) }
        expect(request_count).to equal(Request.all.size)
      end

      it 'returns a success response (i.e. to display the "new" template)' do
        post :create, params: { request: invalid_attributes }
        expect(response).to be_successful
      end

      # regression test for #320
      it 'assigns the sudo users to the request' do
        post :create, params: { request: invalid_attributes }
        expect(assigns(:request).sudo_users).to match_array([sudo_user])
      end

      # regression test for #320
      it 'does not persist the sudo users' do
        post :create, params: { request: invalid_attributes }
        expect(assigns(:request).sudo_user_assignments).to all(be_changed)
      end
    end
 
      context 'with to high resource params' do
        it 'does not create a request' do
          request_count = Request.all.size
          post :create, params: { request: to_high_resource_attributes }
          expect(request_count).to equal(Request.all.size)
        end

        it 'returns a success response' do
          post :create, params: { request: to_high_resource_attributes }
          expect(response).to be_successful
        end 
      end
  end

  describe 'PATCH #reject' do
    let(:rejection_information) do
      'I do not want this request'
    end

    let(:rejection_attributes) do
      { rejection_information: rejection_information }
    end

    let(:the_request) do
      Request.create! valid_attributes
    end

    it 'rejects the request' do
      patch :reject, params: { id: the_request.to_param, request: rejection_attributes }
      the_request.reload
      expect(the_request).to be_rejected
    end

    it 'updates the rejection information' do
      patch :reject, params: { id: the_request.to_param, request: rejection_attributes }
      the_request.reload
      expect(the_request.rejection_information).to eql(rejection_information)
    end

    it 'redirects to requests page' do
      patch :reject, params: { id: the_request.to_param, request: rejection_attributes }
      expect(response).to redirect_to(requests_path)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          name: 'mynewvm',
          cpu_cores: 3,
          ram_gb: 2,
          storage_gb: 3,
          operating_system: 'MyNewOS',
          comment: 'newComment',
          status: 'pending',
          user: user,
          sudo_user_ids: ['', sudo_user.id.to_s, user.id.to_s],
          user_ids: ['']
        }
      end

      # this variable may not be called request, because it would then override an internal RSpec variable
      let(:the_request) do
        request = Request.create! valid_attributes
        request.assign_sudo_users valid_attributes[:sudo_user_ids][1..-1]
        request.save!
        request
      end

      before do
        patch :update, params: { id: the_request.to_param, request: new_attributes }
        the_request.reload
      end

      it 'updates the request' do
        expect(the_request.name).to eq('mynewvm')
      end

      it 'redirects to the new VMS config' do
        expect(response).to redirect_to(edit_config_path(the_request.name))
      end

      it 'accepts the request' do
        expect(the_request).to be_accepted
      end

      it 'correctly updates the sudo users' do
        expect(the_request.sudo_users).to match_array([sudo_user, user])
      end
    end

    context 'with invalid params' do
      let(:the_request) do
        Request.create! valid_attributes
      end

      it 'returns a success respond (i.e. to display the "edit" template)' do
        patch :update, params: { id: the_request.to_param, request: invalid_attributes }
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

  describe 'POST #push_to_git' do
    before do
      request = Request.create! valid_attributes
      allow(request).to receive(:push_to_git).and_return(notice: 'Successfully pushed to git.')
      request_class = class_double('Request')
                      .as_stubbed_const(transfer_nested_constants: true)

      expect(request_class).to receive(:find) { request }
    end

    it 'redirects with a success message' do
      post :push_to_git, params: { id: request.to_param }
      expect(response).to redirect_to(requests_url)
    end
  end
end
