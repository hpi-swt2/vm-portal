# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VmController, type: :controller do
  describe 'GET #index' do

    before :each do
      double_api = double
      expect(double_api).to receive(:all_vms).and_return [{name:'My insanely cool vm', state: true, boot_time: 'Thursday'}]
      expect(double_api).to receive(:all_hosts).and_return [{
                                                                name: 'someHostMachine',
                                                                cores: 99,
                                                                threads: 99,
                                                                stats: {
                                                                    usedCPU: 3,
                                                                    totalCPU: 4,
                                                                    usedMem: 5,
                                                                    totalMem: 6
                                                                }
                                                            }]
      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders index page' do
      expect(get :index).to render_template('vm/index')
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      double_api = double
      expect(double_api).to receive(:delete_vm)
      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      delete :destroy, params: {id: 'my insanely cool vm'}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before :each do
      double_api = double
      expect(double_api).to receive(:create_vm)
      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      post :create, params: {name: 'My insanely cool vm', ram: '1024', capacity: '10000', cpu: 2}
      expect(response).to redirect_to(vm_index_path)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders new page' do
      expect(get :new).to render_template('vm/new')
    end

  end
end
