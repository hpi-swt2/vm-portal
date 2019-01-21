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
    v_sphere_vm_mock 'My insanely cool vm', power_state: 'poweredOn', boot_time: 'Thursday', vm_ware_tools: 'toolsInstalled'
  end

  describe 'GET #index' do
    before do
      vm1

      # associate vm2 with the user
      request = FactoryBot.create :accepted_request
      request.users << current_user
      vm2 = v_sphere_vm_mock request.name, power_state: 'poweredOff', boot_time: 'now', vm_ware_tools: 'toolsInstalled'

      allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock([vm1, vm2], [], [], [], [])
    end

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
    context 'when vm is found' do
      before do
        allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      end

      context 'when current user is user' do
        context 'when user is associated to vm' do
          before do
            FactoryBot.create :accepted_request, name: vm1.name, users: [current_user]
          end

          it 'renders show page' do
            expect(get(:show, params: { id: vm1.name })).to render_template('vms/show')
          end
        end

        context 'when user is not associated to vm' do

          it 'redirects' do
            get :show, params: { id: vm1.name }
            expect(response).to have_http_status (:redirect)
          end
        end
      end

      context 'when current user is admin' do
        let(:current_user) { FactoryBot.create :admin }

        context 'when user is associated to vm' do
          before do
            FactoryBot.create :accepted_request, name: vm1.name, users: [current_user]
          end

          it 'renders show page' do
            expect(get(:show, params: { id: vm1.name })).to render_template('vms/show')
          end
        end

        context 'when user is not associated to vm' do

          it 'renders show page' do
            expect(get(:show, params: { id: vm1.name })).to render_template('vms/show')
          end
        end
      end
    end

    context 'when no vm found' do
      before do
        allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return nil
      end

      it 'returns http status not found when no vm found' do
        get :show, params: { id: 5 }
        expect(response).to have_http_status(:not_found)
      end

      it 'renders not found page when no vm found' do
        expect(get(:show, params: { id: vm1.name })).to render_template('errors/not_found')
      end
    end
  end

  let(:old_path) { 'old_path' }

  def set_old_path
    request.env['HTTP_REFERER'] = 'old_path' unless request.nil? || request.env.nil?
  end


  describe 'POST #change_power_state' do
    before do
      allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      set_old_path
    end

    context 'when the current_user is a root_user' do
      before do
        vm_request = FactoryBot.create :accepted_request, name: vm1.name
        FactoryBot.create :users_assigned_to_request, request: vm_request, user: current_user, sudo: true
        expect(vm1).to receive(:change_power_state)
        post :change_power_state, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to the path the user came from' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :change_power_state, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(vms_path)
      end
    end
  end

  describe 'POST #suspend_vm' do
    before do
      allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      set_old_path
    end

    context 'when the current_user is a root_user' do
      before do
        vm_request = FactoryBot.create :accepted_request, name: vm1.name
        FactoryBot.create :users_assigned_to_request, request: vm_request, user: current_user, sudo: true
        expect(vm1).to receive(:suspend_vm)
        post :suspend_vm, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to the path the user came from' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :suspend_vm, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(vms_path)
      end
    end
  end

  describe 'POST #shutdown_guest_os' do
    before do
      allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      set_old_path
    end

    context 'when the current_user is a root_user' do
      before do
        vm_request = FactoryBot.create :accepted_request, name: vm1.name
        FactoryBot.create :users_assigned_to_request, request: vm_request, user: current_user, sudo: true
        expect(vm1).to receive(:shutdown_guest_os)
        post :shutdown_guest_os, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to the path the user came from' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :shutdown_guest_os, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(vms_path)
      end
    end
  end

  describe 'POST #reboot_guest_os' do
    before do
      allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      set_old_path
    end

    context 'when the current_user is a root_user' do
      before do
        vm_request = FactoryBot.create :accepted_request, name: vm1.name
        FactoryBot.create :users_assigned_to_request, request: vm_request, user: current_user, sudo: true
        expect(vm1).to receive(:reboot_guest_os)
        post :reboot_guest_os, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to the path the user came from' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :reboot_guest_os, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(vms_path)
      end
    end
  end

  describe 'POST #reset_vm' do
    before do
      allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      set_old_path
    end

    context 'when the current_user is a root_user' do
      before do
        vm_request = FactoryBot.create :accepted_request, name: vm1.name
        FactoryBot.create :users_assigned_to_request, request: vm_request, user: current_user, sudo: true
        expect(vm1).to receive(:reset_vm)
        post :reset_vm, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to the path the user came from' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :reset_vm, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(vms_path)
      end
    end
  end
end
