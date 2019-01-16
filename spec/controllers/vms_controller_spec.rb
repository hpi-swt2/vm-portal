# frozen_string_literal: true

require 'rails_helper'
RSpec.describe VmsController, type: :controller do
  let(:current_user) { FactoryBot.create :user }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in current_user
  end

  describe 'GET #index' do
    before do
      vm1 = { name: 'My insanely cool vm', state: true, boot_time: 'Thursday', vmwaretools: true }
      vm2 = { name: 'another VM', state: false, boot_time: 'now', vmwaretools: true }
      double_api = double
      allow(double_api).to receive(:all_vm_infos).and_return [vm1, vm2]
      allow(double_api).to receive(:ensure_folder)
      allow(double_api).to receive(:all_vms_in).and_return []
      allow(double_api).to receive(:user_vms).and_return [vm1]

      allow(VmApi).to receive(:instance).and_return double_api
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
        expect(subject.vms.size).to be VmApi.instance.all_vm_infos.size
      end

      it 'returns online VMs if requested' do
        get :index, params: { up_vms: 'true' }
        expect(subject.vms).to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
        expect(subject.vms).not_to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
      end

      it 'returns offline VMs if requested' do
        get :index, params: { down_vms: 'true' }
        expect(subject.vms).to satisfy('include offline VMs') { |vms| vms.any? { |vm| !vm[:state] } }
        expect(subject.vms).not_to satisfy('include online VMs') { |vms| vms.any? { |vm| vm[:state] } }
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
      @vm1 = { name: 'My insanely cool vm', state: true, boot_time: 'Thursday', vmwaretools: true }
      allow(double_api).to receive(:user_vms).and_return [@vm1]
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success or timeout or not found' do
      allow(double_api).to receive(:get_vm_info).and_return(@vm1)
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success).or have_http_status(408)
    end

    context 'when current user is user' do
      context 'when user is associated to vm' do
        before do
          allow(double_api).to receive(:get_vm_info).and_return(@vm1)
        end

        it 'renders show page' do
          expect(get(:show, params: { id: 1 })).to render_template('vms/show')
        end
      end

      context 'when user is not associated to vm' do
        before do
          allow(double_api).to receive(:get_vm_info).and_return({})
        end

        it 'redirects' do
          get :show, params: { id: 1 }
          expect(response).to have_http_status 302
        end
      end
    end

    context 'when current user is admin' do
      context 'when user is associated to vm' do
        before do
          allow(double_api).to receive(:get_vm_info).and_return(@vm1)
        end

        it 'renders show page' do
          expect(get(:show, params: { id: 1 })).to render_template('vms/show')
        end
      end

      context 'when user is not associated to vm' do
        before do
          allow(double_api).to receive(:get_vm_info).and_return(@vm1)
        end

        it 'renders show page' do
          expect(get(:show, params: { id: 1 })).to render_template('vms/show')
        end
      end
    end

    it 'returns http status not found when no vm found' do
      allow(double_api).to receive(:get_vm_info).and_return(nil)
      get :show, params: { id: 5 }
      expect(response).to have_http_status(:not_found)
    end

    it 'renders not found page when no vm found' do
      allow(double_api).to receive(:get_vm_info).and_return(nil)
      expect(get(:show, params: { id: 1 })).to render_template('errors/not_found')
    end
  end

  describe 'POST #change_power_state' do
    before do
      double_api = double
      expect(double_api).to receive(:change_power_state)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :change_power_state, params: { id: 0 }
      expect(response).to redirect_to("where_i_came_from")
    end
  end

  describe 'POST #suspend_vm' do
    before do
      double_api = double
      expect(double_api).to receive(:suspend_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :suspend_vm, params: { id: 0 }
      expect(response).to redirect_to("where_i_came_from")
    end
  end

  describe 'POST #shutdown_guest_os' do
    before do
      double_api = double
      expect(double_api).to receive(:shutdown_guest_os)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :shutdown_guest_os, params: { id: 0 }
      expect(response).to redirect_to("where_i_came_from")
    end
  end

  describe 'POST #reboot_guest_os' do
    before do
      double_api = double
      expect(double_api).to receive(:reboot_guest_os)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :reboot_guest_os, params: { id: 0 }
      expect(response).to redirect_to("where_i_came_from")
    end
  end

  describe 'POST #reset_vm' do
    before do
      double_api = double
      expect(double_api).to receive(:reset_vm)
      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:get_vm_info).and_return({})
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
    end

    it 'returns http success and redirects to previous location' do
      post :reset_vm, params: { id: 0 }
      expect(response).to redirect_to("where_i_came_from")
    end
  end
end
