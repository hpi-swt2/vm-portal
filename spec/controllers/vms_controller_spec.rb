# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

RSpec.describe VmsController, type: :controller do
  let(:current_user) { FactoryBot.create :user }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in current_user
  end

  let(:vm1) do
    vm1 = v_sphere_vm_mock 'My insanely cool vm', power_state: 'poweredOn', boot_time: 'Thursday', vm_ware_tools: 'toolsInstalled'
  end

  let(:vm2) do
    # associate vm2 with the user
    request = FactoryBot.create :accepted_request
    request.users << current_user
    v_sphere_vm_mock request.name, power_state: 'poweredOff', boot_time: 'now', vm_ware_tools: 'toolsInstalled'
  end

  before do
    allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock([vm1, vm2], [], [], [], [])
  end

  describe 'GET #index' do



    context 'when the current user is a user' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders index page' do
        expect(get(:index)).to render_template('vms/index')
      end

      it 'returns only vms associated to current user' do
        get :index
        expect(subject.vms.size).to be 1
      end
    end

    context 'when the current user is an employee' do
      let(:current_user) { FactoryBot.create :employee }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders index page' do
        expect(get(:index)).to render_template('vms/index')
      end

      it 'returns only vms associated to current user' do
        get :index
        expect(subject.vms.size).to be 1
      end
    end

    context 'when the current user is an admin' do
      let(:current_user) { FactoryBot.create :admin }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders index page' do
        expect(get(:index)).to render_template('vms/index')
      end

      it 'returns all VMs' do
        get(:index)
        expect(subject.vms.size).to be VSphere::VirtualMachine.all.size
      end

      it 'returns online VMs if requested' do
        get :index, params: { up_vms: 'true' }
        expect(subject.vms).to satisfy('include online VMs') { |vms| vms.any?(&:powered_on?) }
        expect(subject.vms).not_to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm.powered_on? } }
      end

      it 'returns offline VMs if requested' do
        get :index, params: { down_vms: 'true' }
        expect(subject.vms).to satisfy('include offline VMs') { |vms| vms.any?(&:powered_off?) }
        expect(subject.vms).not_to satisfy('include online VMs') { |vms| vms.any? { |vm| !vm.powered_off? } }
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

  describe 'GET #show' do
    it 'returns http success or timeout or not found' do
      get :show, params: { id: vm2.name }
      expect(response).to have_http_status(:success).or have_http_status(408)
    end

    context 'when current user is user' do
      context 'when user is associated to vm' do
        it 'renders show page' do
          expect(get(:show, params: { id: vm2.name })).to render_template('vms/show')
        end
      end

      context 'when user is not associated to vm' do
        it 'redirects' do
          get :show, params: { id: vm1.name }
          expect(response).to have_http_status 302
        end
      end
    end

    context 'when current user is admin' do
      let(:current_user) { FactoryBot.create :admin }

      context 'when user is associated to vm' do
        it 'renders show page' do
          expect(get(:show, params: { id: vm2.name })).to render_template('vms/show')
        end
      end

      context 'when user is not associated to vm' do
        it 'renders show page' do
          expect(get(:show, params: { id: vm1.name })).to render_template('vms/show')
        end
      end
    end

    it 'returns http status not found when no vm found' do
      get :show, params: { id: 5 }
      expect(response).to have_http_status(:not_found)
    end

    it 'renders not found page when no vm found' do
      expect(get(:show, params: { id: 1 })).to render_template('errors/not_found')
    end
  end

  describe 'POST #change_power_state' do
    before do
      double_api = double
      expect(double_api).to receive(:change_power_state)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env['HTTP_REFERER'] = 'where_i_came_from' unless request.nil? || request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :change_power_state, params: { id: 0 }
      expect(response).to redirect_to('where_i_came_from')
    end
  end

  describe 'POST #suspend_vm' do
    before do
      double_api = double
      expect(double_api).to receive(:suspend_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env['HTTP_REFERER'] = 'where_i_came_from' unless request.nil? || request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :suspend_vm, params: { id: 0 }
      expect(response).to redirect_to('where_i_came_from')
    end
  end

  describe 'POST #shutdown_guest_os' do
    before do
      double_api = double
      expect(double_api).to receive(:shutdown_guest_os)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env['HTTP_REFERER'] = 'where_i_came_from' unless request.nil? || request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :shutdown_guest_os, params: { id: 0 }
      expect(response).to redirect_to('where_i_came_from')
    end
  end

  describe 'POST #reboot_guest_os' do
    before do
      double_api = double
      expect(double_api).to receive(:reboot_guest_os)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env['HTTP_REFERER'] = 'where_i_came_from' unless request.nil? || request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :reboot_guest_os, params: { id: 0 }
      expect(response).to redirect_to('where_i_came_from')
    end
  end

  describe 'POST #reset_vm' do
    before do
      double_api = double
      expect(double_api).to receive(:reset_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env['HTTP_REFERER'] = 'where_i_came_from' unless request.nil? || request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :reset_vm, params: { id: 0 }
      expect(response).to redirect_to('where_i_came_from')
    end
  end
end
