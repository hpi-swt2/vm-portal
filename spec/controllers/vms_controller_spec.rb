# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

# rubocop:disable RSpec/NestedGroups
RSpec.describe VmsController, type: :controller do
  let(:current_user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }

  let(:vm1) do
    v_sphere_vm_mock 'my-insanely-cool-vm', power_state: 'poweredOn', boot_time: 'Thursday', vm_ware_tools: 'toolsInstalled'
  end

  let(:vm2) do
    # associate vm2 with the user
    vm = v_sphere_vm_mock 'myVM', power_state: 'poweredOff', boot_time: 'now', vm_ware_tools: 'toolsInstalled'
    associate_users_with_vms(users: [current_user], vms: [vm])
    vm
  end

  let(:vm_request) { FactoryBot.create :accepted_request, users: [current_user] }
  let(:old_path) { 'old_path' }

  let(:config) do
    config = FactoryBot.create :virtual_machine_config
    config.name = vm1.name
    config.save!
    config
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in current_user
    allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock(normal_vms: [vm1, vm2])
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
        puts subject.vms
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
    end
  end

  describe 'POST #create' do
    let(:double_api) { double }

    before do
      allow(double_api).to receive(:create_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      post :create, params: { name: 'My insanely cool vm', ram: '1024', capacity: '10000', cpu: 2 }
    end

    it 'has received create_vm' do
      expect(double_api).to have_received(:create_vm)
    end

    it 'returns http success' do
      expect(response).to redirect_to(vms_path)
    end
  end

  describe 'PATCH #update' do
    before do
      sign_in admin
      allow(vm1).to receive(:users=)
      allow(vm1).to receive(:sudo_users=)
      allow(vm1).to receive(:config).and_return config
      allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm1
      @description = 'oh how nice is panama'
      @sudo_user_ids = [admin.id.to_s]
      @non_sudo_user_ids = [current_user.id.to_s]
      patch :update, params: { id: vm1.name, vm_info: { sudo_user_ids: @sudo_user_ids, non_sudo_user_ids: @non_sudo_user_ids, description: @description } }
    end

    it 'calls set_sudo_users on vm' do
      expect(vm1).to have_received('sudo_users=').with(@sudo_user_ids)
    end

    it 'calls set_users on vm' do
      expect(vm1).to have_received('users=').with(@non_sudo_user_ids)
    end

    it 'saves the new description in config' do
      expect(VirtualMachineConfig.find(config.id).description).to eq(@description)
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
            associate_users_with_vms(users: [current_user], vms: [vm1])
          end

          it 'renders show page' do
            expect(get(:show, params: { id: vm1.name })).to render_template('vms/show')
          end
        end

        context 'when user is not associated to vm' do
          it 'redirects' do
            get :show, params: { id: vm1.name }
            expect(response).to have_http_status :redirect
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
        associate_users_with_vms(admins: [current_user], vms: [vm1])
        allow(vm1).to receive(:change_power_state)
        post :change_power_state, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:change_power_state)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is an admin' do
      let(:current_user) { admin }

      before do
        allow(vm1).to receive(:change_power_state)
        post :change_power_state, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:change_power_state)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :change_power_state, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to vms_path' do
        expect(response).to redirect_to(vms_path)
      end
    end

    context 'when the vm requires more resouces than any host can provide' do
      let(:current_user) { admin }

      before do
        summary_double = double
        allow(summary_double).to receive_message_chain(:config, :numCpu).and_return(999)
        allow(VSphere::VirtualMachine).to receive(:find_by_name).and_return vm2
        allow(vm2).to receive(:summary).and_return(summary_double)
        allow(vm2).to receive(:change_power_state).and_raise(RbVmomi::Fault.new('NotEnoughCpus:', nil))

        post :change_power_state, params: { id: vm2.name }
      end

      it 'catches the error' do
        expect { post :change_power_state, params: { id: vm2.name } }.not_to raise_error
      end

      it 'redirects to the details page of the vm' do
        expect(response).to redirect_to(old_path)
      end

      it 'delivers a flash[:alert] banner' do
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/NotEnoughCpus:.*/)
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
        associate_users_with_vms(admins: [current_user], vms: [vm1])
        allow(vm1).to receive(:suspend_vm)
        post :suspend_vm, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:suspend_vm)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is an admin' do
      let(:current_user) { admin }

      before do
        allow(vm1).to receive(:suspend_vm)
        post :suspend_vm, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:suspend_vm)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :suspend_vm, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to vms_path' do
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
        associate_users_with_vms(admins: [current_user], vms: [vm1])
        allow(vm1).to receive(:shutdown_guest_os)
        post :shutdown_guest_os, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:shutdown_guest_os)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is an admin' do
      let(:current_user) { admin }

      before do
        allow(vm1).to receive(:shutdown_guest_os)
        post :shutdown_guest_os, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:shutdown_guest_os)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :shutdown_guest_os, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to vms_path' do
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
        associate_users_with_vms(admins: [current_user], vms: [vm1])
        allow(vm1).to receive(:reboot_guest_os)
        post :reboot_guest_os, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:reboot_guest_os)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is an admin' do
      let(:current_user) { admin }

      before do
        allow(vm1).to receive(:reboot_guest_os)
        post :reboot_guest_os, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:reboot_guest_os)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :reboot_guest_os, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to vms_path' do
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
        associate_users_with_vms(admins: [current_user], vms: [vm1])
        allow(vm1).to receive(:reset_vm)
        post :reset_vm, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:reset_vm)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is an admin' do
      let(:current_user) { admin }

      before do
        allow(vm1).to receive(:reset_vm)
        post :reset_vm, params: { id: vm1.name }
      end

      it 'calls the vms action' do
        expect(vm1).to have_received(:reset_vm)
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the path the user came from' do
        expect(response).to redirect_to(old_path)
      end
    end

    context 'when the current_user is not a root_user' do
      before do
        post :reset_vm, params: { id: vm1.name }
      end

      it 'returns http redirect and redirects to vms_path' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to vms_path' do
        expect(response).to redirect_to(vms_path)
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
