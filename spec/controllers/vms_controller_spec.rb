# frozen_string_literal: true

require 'rails_helper'
RSpec.describe VmsController, type: :controller do
  # Authenticate an user
  before do
    sign_in FactoryBot.create :user
  end

  describe 'GET #index' do
    before do
      double_api = double
      allow(double_api).to receive(:all_vms).and_return [{ name: 'My insanely cool vm', state: true, boot_time: 'Thursday', vmwaretools: true },
                                                         { name: 'another VM', state: false, boot_time: 'now', vmwaretools: true }]

      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders index page' do
      expect(get(:index)).to render_template('vms/index')
    end

    it 'returns all VMs per default' do
      controller = VmsController.new
      controller.params = {}
      controller.index
      expect(controller.vms.size).to be VmApi.instance.all_vms.size
    end

    it 'returns online VMs if requested' do
      controller = VmsController.new
      controller.params = { up_vms: 'true' }
      controller.index
      expect(controller.vms).to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
      expect(controller.vms).not_to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
    end

    it 'returns offline VMs if requested' do
      controller = VmsController.new
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
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success' do
      delete :destroy, params: { id: 'my insanely cool vm' }
      expect(response).to have_http_status(:success)
      skip
    end
  end

  describe 'POST #create' do
    before do
      double_api = double
      expect(double_api).to receive(:create_vm)
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success' do
      post :create, params: { name: 'My insanely cool vm', ram: '1024', capacity: '10000', cpu: 2 }
      expect(response).to redirect_to(vms_path)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders new page' do
      expect(get(:new)).to render_template('vms/new')
    end
  end

  describe 'GET #show' do
    let(:double_api) do
      double
    end

    before do
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success or timeout or not found' do
      allow(double_api).to receive(:get_vm).and_return({})
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success).or have_http_status(408)
    end

    it 'renders show page' do
      allow(double_api).to receive(:get_vm).and_return({})
      expect(get(:show, params: { id: 1 })).to render_template('vms/show')
    end

    it 'returns http status not found when no vm found' do
      allow(double_api).to receive(:get_vm).and_return(nil)
      get :show, params: { id: 5 }
      expect(response).to have_http_status(:not_found)
    end

    it 'renders not found page when no vm found' do
      allow(double_api).to receive(:get_vm).and_return(nil)
      expect(get(:show, params: { id: 1 })).to render_template('errors/not_found')
    end
  end

  describe 'POST #change_power_state' do
    let(:double_api) do
      double
    end

    before do
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success or timeout or not found' do
      allow(double_api).to receive(:get_vm).and_return({})
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success).or have_http_status(408)
    end
  end

  describe 'POST #suspend_vm' do
    pending 'should '
  end

  describe 'POST #resume' do
    pending 'should '
  end

  describe 'POST #shutdown_guest_os' do
    pending 'should '
  end

  describe 'POST #reboot_guest_os' do
    pending 'should '
  end

  describe 'POST #reset_vm' do
    pending 'should '
  end
end
