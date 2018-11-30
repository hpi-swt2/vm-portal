# frozen_string_literal: true

require 'rails_helper'
RSpec.describe VmController, type: :controller do
  # Authenticate an user
  before do
    user = FactoryBot.create :user
    sign_in user
  end

  describe 'GET #index' do
    before do
      double_api = double
      allow(double_api).to receive(:all_vms).and_return [{ name: 'My insanely cool vm', state: true, boot_time: 'Thursday' },
                                                         { name: 'another VM', state: false, bootTime: 'now' }]

      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:connected?).and_return true

      double_flash = double
      allow(double_flash).to receive(:discard)
      allow_any_instance_of(VmController).to receive(:flash).and_return(double_flash)
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
      expect(controller.vms.size).to be VmApi.instance.all_vms.size
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
  end

  describe 'DELETE #destroy' do
    before do
      double_api = double
      expect(double_api).to receive(:delete_vm)
      allow(double_api).to receive(:connected?).and_return true
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success' do
      delete :destroy, params: { id: 'my insanely cool vm' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      double_api = double
      expect(double_api).to receive(:create_vm)
      allow(double_api).to receive(:connected?).and_return true
      allow(VmApi).to receive(:instance).and_return double_api
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
      allow(double_api).to receive(:connected?).and_return true
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
end
