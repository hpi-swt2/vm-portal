# frozen_string_literal: true

require 'rails_helper'
RSpec.describe VmsController, type: :controller do
  # Authenticate an user
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = FactoryBot.create :user
    sign_in @user
  end

  describe 'GET #index' do
    context 'when the user is admin' do
      before do
        @user = FactoryBot.create :admin
        sign_in @user
        @request1 = FactoryBot.create :request, name: "My insanely cool vm"
        @request1.accept!
        @request1.users << @user
        @request2 = FactoryBot.create :request, name: "another vm"
        vm1 = { name: 'My insanely cool vm', state: true, boot_time: 'Thursday', vmwaretools: true, request: @request1 }
        vm2 = { name: 'another VM', state: false, boot_time: 'now', vmwaretools: true, request: @request2 }
        double_api = double
        allow(double_api).to receive(:all_vms).and_return [vm1, vm2]
        allow(VmApi).to receive(:instance).and_return double_api
      end

      it 'returns http success' do
        get :index
        response.should be_success
      end

      it 'renders index page' do
        expect(get(:index)).to render_template('vms/index')
      end

      it 'returns all vms' do
        get 'index'
        expect(subject.vms.size).to be VmApi.instance.all_vms.size
      end

      it 'returns online VMs if requested' do
        subject.params = { up_vms: 'true' }
        subject.index
        expect(subject.vms).to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
        expect(subject.vms).not_to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
      end

      it 'returns offline VMs if requested' do
        subject.params = { down_vms: 'true' }
        subject.index
        expect(subject.vms).to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
        expect(subject.vms).not_to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
      end
    end

    context 'when the user is user' do
      before do
        @request1 = FactoryBot.create :request, name: "My insanely cool vm"
        @request1.accept!
        @request1.users << @user
        @request1.save
        @request2 = FactoryBot.create :request, name: "another vm"
        vm1 = { name: 'My insanely cool vm', state: true, boot_time: 'Thursday', vmwaretools: true, request: @request1 }
        vm2 = { name: 'another VM', state: false, boot_time: 'now', vmwaretools: true, request: @request2 }
        double_api = double
        allow(double_api).to receive(:all_vms).and_return [vm1, vm2]
        allow(VmApi).to receive(:instance).and_return double_api
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders index page' do
        expect(get(:index)).to render_template('vms/index')
      end

      it 'returns vms for current user' do
        subject.params = {}
        subject.index
        controller.vms.size.should be 1
      end
    end

  end

  describe 'DELETE #destroy' do
    before do
      double_api = double
      expect(double_api).to receive(:delete_vm)
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success' do
      expect(subject.current_user).to_not eq(nil)
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
      sign_in FactoryBot.create :admin
      allow(double_api).to receive(:get_vm).and_return({})
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success).or have_http_status(408)
    end

    it 'renders show page' do
      sign_in FactoryBot.create :admin
      allow(double_api).to receive(:get_vm).and_return({})
      expect(get(:show, params: { id: 1 })).to render_template('vms/show')
    end

    it 'returns http status not found when no vm found' do
      sign_in FactoryBot.create :admin
      allow(double_api).to receive(:get_vm).and_return(nil)
      get :show, params: { id: 5 }
      expect(response).to have_http_status(:not_found)
    end

    it 'renders not found page when no vm found' do
      sign_in FactoryBot.create :admin
      allow(double_api).to receive(:get_vm).and_return(nil)
      expect(get(:show, params: { id: 1 })).to render_template('errors/not_found')
    end
  end

  describe 'POST #change_power_state' do
    before do
      double_api = double
      expect(double_api).to receive(:change_power_state)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm).and_return({})
    end

    it 'returns http success' do
      post :change_power_state, params: { id: 0 }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST #suspend_vm' do
    before do
      double_api = double
      expect(double_api).to receive(:suspend_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm).and_return({})
    end

    it 'returns http success' do
      post :suspend_vm, params: { id: 0 }
      expect(response).to redirect_to(vm_path)
    end
  end

  describe 'POST #shutdown_guest_os' do
    before do
      double_api = double
      expect(double_api).to receive(:shutdown_guest_os)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm).and_return({})
    end

    it 'returns http success' do
      post :shutdown_guest_os, params: { id: 0 }
      expect(response).to redirect_to(vm_path)
    end
  end

  describe 'POST #reboot_guest_os' do
    before do
      double_api = double
      expect(double_api).to receive(:reboot_guest_os)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm).and_return({})
    end

    it 'returns http success' do
      post :reboot_guest_os, params: { id: 0 }
      expect(response).to redirect_to(vm_path)
    end
  end

  describe 'POST #reset_vm' do
    before do
      double_api = double
      expect(double_api).to receive(:reset_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm).and_return({})
    end

    it 'returns http success' do
      post :reset_vm, params: { id: 0 }
      expect(response).to redirect_to(vm_path)
    end
  end
end
