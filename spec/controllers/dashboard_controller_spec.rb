# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) {FactoryBot.create :user}

  let(:vm1) do
    vm = v_sphere_vm_mock 'my-insanely-cool-vm', power_state: 'poweredOn', vm_ware_tools: 'toolsInstalled'
    associate_users_with_vms(users: [user], vms: [vm])
    vm
  end

  let(:vm2) do
    v_sphere_vm_mock 'not-my-vm', power_state: 'poweredOn', vm_ware_tools: 'toolsInstalled'
  end

  before do
    allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock(normal_vms: [vm1, vm2])
  end

  describe 'GET #index"' do
    context 'when logged in as a user' do
      before do
        sign_in(user)
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'returns only vms associated to current user' do
        get :index
        expect(subject.vms.size).to be 1
      end
    end

    context 'when logged in as an admin' do
      let(:user) {FactoryBot.create :admin}

      before do
        sign_in(user)
      end

      it 'returns all vms' do
        get :index
        expect(subject.vms.size).to be 2
      end
    end

    context 'when logged out' do
      it 'redirects to the login page' do
        get(:index)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
