# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VmController, type: :controller do
  describe 'GET #index' do
    before do
      double_api = double
      allow(double_api).to receive(:all_vms).and_return [{ name: 'My insanely cool vm', state: true, boot_time: 'Thursday' },
                                                          { name: 'another VM', state: false, bootTime: 'now' }]
      allow(double_api).to receive(:all_hosts).and_return [{ name: 'someHostMachine', connectionState: 'connected' },
                                                            { name: 'anotherHost', connectionState: 'not connected' }]

      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders index page' do
      expect(get(:index)).to render_template('vm/index')
    end

    it 'returns all VMs per default' do
      controller = VmController.new
      controller.params = {}
      controller.index
      expect(controller.vms.size).to be VmApi.new.all_vms.size
    end

    it 'returns all hosts per default' do
      controller = VmController.new
      controller.params = {}
      controller.index
      expect(controller.hosts.size).to be VmApi.new.all_hosts.size
    end

    it 'returns online VMs if requested' do
      controller = VmController.new
      controller.params = { up_vms: 'true' }
      controller.index
      expect(controller.vms).to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
      expect(controller.vms).not_to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
    end

    it 'returns offline VMs if requested' do
      controller = VmController.new
      controller.params = { down_vms: 'true' }
      controller.index
      expect(controller.vms).to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
      expect(controller.vms).not_to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
    end

    it 'returns online hosts if requested' do
      controller = VmController.new
      controller.params = { up_hosts: 'true' }
      controller.index
      expect(controller.hosts).to satisfy('include online hosts') { |hosts| hosts.any? { |host| host[:connectionState] == 'connected' } }
      expect(controller.hosts).not_to satisfy('include offline hosts') { |hosts| hosts.any? { |host| host[:connectionState] != 'connected' } }
    end

    it 'returns offline hosts if requested' do
      controller = VmController.new
      controller.params = { down_hosts: 'true' }
      controller.index
      expect(controller.hosts).to satisfy('include offline hosts') { |hosts| hosts.any? { |host| host[:connectionState] != 'connected' } }
      expect(controller.hosts).not_to satisfy('include online hosts') { |hosts| hosts.any? { |host| host[:connectionState] == 'connected' } }
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      double_api = double
      expect(double_api).to receive(:delete_vm)
      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      delete :destroy, params: { id: 'my insanely cool vm' }
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
      post :create, params: { name: 'My insanely cool vm', ram: '1024', capacity: '10000', cpu: 2 }
      expect(response).to redirect_to(vm_index_path)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders new page' do
      expect(get(:new)).to render_template('vm/new')
    end
  end

  describe 'get #show' do
    before do
      double_api = double
      allow(double_api).to receive(:get_vm).and_return(nil)
      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success)
    end

    it 'renders show page' do
      expect(get(:show, params: { id: 1 })).to render_template('vm/show')
    end
  end

  describe 'get #show_host' do
    before do
      double_api = double
      allow(double_api).to receive(:get_host).and_return(nil)
      allow(VmApi).to receive(:new).and_return double_api
    end

    it 'returns http success' do
      get :show_host, params: { id: 1 }
      expect(response).to have_http_status(:success)
    end

    it 'renders show page' do
      expect(get(:show_host, params: { id: 1 })).to render_template('vm/show_host')
    end
  end
end
