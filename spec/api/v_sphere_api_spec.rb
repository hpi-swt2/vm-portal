# frozen_string_literal: true

require 'rails_helper'

require './app/api/v_sphere/folder'
require './app/api/v_sphere/virtual_machine'
require './app/api/v_sphere/connection'
require_relative 'v_sphere_api_mocker'

# We really want to be able to stub message chains in this Spec, because the API that is provided by vSphere
# has many messages that have to be chained which we want to mock.
# rubocop:disable RSpec/MessageChain
describe VSphere do
  let(:mock_archived_vms) do
    (1..5).map do |each|
      vim_vm_mock('Archived VM' + each.to_s, power_state: 'poweredOff')
    end
  end

  let(:mock_archived_vms_folder) do
    vim_folder_mock('Archived VMs', [], mock_archived_vms, [])
  end

  let(:mock_pending_archivings_vms) do
    (1..5).map do |each|
      vim_vm_mock('Pending Archiving VM' + each.to_s)
    end
  end

  let(:mock_pending_archivings_folder) do
    vim_folder_mock('Pending archivings', [], mock_pending_archivings_vms, [])
  end

  let(:mock_pending_revivings_vms) do
    (1..5).map do |each|
      vim_vm_mock('Pending Revivings VM' + each.to_s)
    end
  end

  let(:mock_pending_revivings_folder) do
    vim_folder_mock('Pending revivings', [], mock_pending_revivings_vms, [])
  end

  let(:mock_root_folder_vms) do
    (1..5).map do |each|
      vim_vm_mock('Root folder VM' + each.to_s, power_state: 'poweredOff')
    end
  end

  let(:user_folder_mock) { vim_folder_mock('user', [], [], []) }

  let(:active_vms_folder) { v_sphere_folder_mock('Active VMs', subfolders: [user_folder_mock]) }

  let(:mock_folder) do
    vim_folder_mock('vm',
                    [mock_archived_vms_folder, mock_pending_archivings_folder, mock_pending_revivings_folder, active_vms_folder],
                    mock_root_folder_vms,
                    [])
  end

  let(:root_folder) { VSphere::Folder.new(mock_folder) }

  let(:cluster1_hosts) do
    [v_sphere_host_mock('test'), v_sphere_host_mock('another test')]
  end

  let(:cluster2_hosts) do
    [v_sphere_host_mock('')]
  end

  let(:clusters_mock) do
    [v_sphere_cluster_mock('cluster1', cluster1_hosts), v_sphere_cluster_mock('cluster2', cluster2_hosts)]
  end

  describe VSphere::Folder do
    it 'finds all vms recursively' do
      vms = (mock_root_folder_vms + mock_archived_vms + mock_pending_archivings_vms +
          mock_pending_revivings_vms).map { |each| VSphere::VirtualMachine.new each }
      expect(root_folder.vms(recursive: true)).to match_array vms
    end

    it 'finds all vms non-recursively' do
      vms = mock_root_folder_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(root_folder.vms(recursive: false)).to match_array vms
    end
  end

  describe VSphere::Cluster do
    before do
      allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock(clusters: clusters_mock)
    end

    it 'Cluster.all finds all clusters' do
      expect(VSphere::Cluster.all).to match_array clusters_mock
    end
  end

  describe VSphere::Host do
    before do
      allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock(clusters: clusters_mock)
    end

    it 'Host.all finds all hosts' do
      expect(VSphere::Host.all).to match_array(cluster1_hosts + cluster2_hosts)
    end
  end

  describe VSphere::VirtualMachine do
    before do
      allow(VSphere::Connection.instance).to receive(:root_folder).and_return(root_folder)
    end

    it 'VirtualMachine.all finds all vms' do
      vms = (mock_root_folder_vms + mock_archived_vms + mock_pending_archivings_vms + mock_pending_revivings_vms).map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.all).to match_array vms
    end

    it 'VirtualMachine.all finds all vms that not have a special status' do
      vms = mock_root_folder_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.rest).to match_array vms
    end

    it 'VirtualMachine.archived finds only archived VMs' do
      vms = mock_archived_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.archived).to match_array vms
    end

    it 'VirtualMachine.pending_archivation finds only vms that are pending archivation' do
      vms = mock_pending_archivings_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.pending_archivation).to match_array vms
    end

    it 'VirtualMachine.pending_archivation finds only vms that are pending reviving' do
      vms = mock_pending_revivings_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.pending_revivings).to match_array vms
    end

    it 'VirtualMachine.find_by_name finds all vms' do
      expect(VSphere::VirtualMachine.find_by_name('Archived VM2')).not_to be_nil
    end

    it 'can move into the responsible users subfolder' do
      config = FactoryBot.create :virtual_machine_config
      config.responsible_users = [FactoryBot.create(:user, email: 'user@user.de')]
      config.save!
      v_sphere_vm_mock(config.name).move_into_correct_subfolder
      expect(user_folder_mock).to have_received(:MoveIntoFolder_Task)
    end

    it 'does not have users if there is no fitting request' do
      expect(VSphere::VirtualMachine.find_by_name('Archived VM2').users).to be_empty
    end

    it 'has users if a fitting request exists' do
      request = FactoryBot.create :accepted_request
      request.users << FactoryBot.create(:user)
      vm = VSphere::VirtualMachine.new(vim_vm_mock(request.name))
      expect(vm.users).to match_array(request.users)
    end

    it 'does not have responsible users if there is no fitting config' do
      expect(VSphere::VirtualMachine.find_by_name('Archived VM2').responsible_users).to be_empty
    end

    it 'has responsible users if a fitting config exists' do
      config = FactoryBot.create :virtual_machine_config
      config.responsible_users << FactoryBot.create(:user)
      vm = v_sphere_vm_mock config.name
      expect(vm.responsible_users).to match_array(config.responsible_users)
    end

    it 'does not have an IP if the fitting config does not exist' do
      vm = v_sphere_vm_mock 'There shall not be a VM config with this name!'
      expect(vm.ip).to be_empty
    end

    it 'has an IP if the fitting config exists' do
      config = FactoryBot.create :virtual_machine_config
      vm = v_sphere_vm_mock config.name
      expect(vm.ip).to be == config.ip
    end

    it 'does not have a dns if the fitting config does not exist' do
      vm = v_sphere_vm_mock 'There shall not be a VM config with this name!'
      expect(vm.dns).to be_empty
    end

    it 'has a dns if the fitting config exists' do
      config = FactoryBot.create :virtual_machine_config
      vm = v_sphere_vm_mock config.name
      expect(vm.dns).to be == config.dns
    end

    it 'knows that it is not archived' do
      non_archived_vms = mock_root_folder_vms.map { |each| VSphere::VirtualMachine.new each }
      non_archived_vms.each { |each| expect(each.archived?).to be false }
    end

    it 'knows that it is archived' do
      archived_vms = mock_archived_vms.map { |each| VSphere::VirtualMachine.new each }
      archived_vms.each { |each| expect(each.archived?).to be true }
    end

    it 'moves into the correct folder when it is archived' do
      vm = VSphere::VirtualMachine.new mock_root_folder_vms.first
      allow(mock_archived_vms_folder).to receive_message_chain :MoveIntoFolder_Task, :wait_for_completion
      vm.set_archived
      expect(mock_archived_vms_folder).to have_received(:MoveIntoFolder_Task)
    end

    it 'moves into the correct folder when it is pending_archivation' do
      vm = VSphere::VirtualMachine.new mock_root_folder_vms.first
      allow(mock_pending_archivings_folder).to receive_message_chain :MoveIntoFolder_Task, :wait_for_completion
      vm.set_pending_archivation
      expect(mock_pending_archivings_folder).to have_received(:MoveIntoFolder_Task)
    end

    it 'moves into the correct folder when it is pending_reviving' do
      vm = VSphere::VirtualMachine.new mock_root_folder_vms.first
      allow(mock_pending_revivings_folder).to receive_message_chain :MoveIntoFolder_Task, :wait_for_completion
      vm.set_pending_reviving
      expect(mock_pending_revivings_folder).to have_received(:MoveIntoFolder_Task)
    end

    it 'moves into the correct folder when it is revived' do
      vm = VSphere::VirtualMachine.new mock_root_folder_vms.first
      allow(mock_folder).to receive_message_chain :MoveIntoFolder_Task, :wait_for_completion
      vm.set_revived
      expect(mock_folder).to have_received(:MoveIntoFolder_Task)
    end

    it 'powers the vm off when its being archived' do # rubocop:disable RSpec/ExampleLength
      vm_mock = vim_vm_mock('My VM', power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled')
      vm = VSphere::VirtualMachine.new vm_mock
      allow(mock_archived_vms_folder).to receive_message_chain :MoveIntoFolder_Task, :wait_for_completion
      allow(vm_mock).to receive_message_chain :PowerOffVM_Task, :wait_for_completion
      vm.set_archived
      expect(vm_mock).to have_received :PowerOffVM_Task
    end

    it 'shuts the vm down when its being archived' do # rubocop:disable RSpec/ExampleLength
      vm_mock = vim_vm_mock('My VM', power_state: 'poweredOn', vm_ware_tools: 'toolsInstalled')
      vm = VSphere::VirtualMachine.new vm_mock
      allow(mock_archived_vms_folder).to receive_message_chain :MoveIntoFolder_Task, :wait_for_completion
      allow(vm_mock).to receive_message_chain :ShutdownGuest, :wait_for_completion
      vm.set_archived
      expect(vm_mock).to have_received :ShutdownGuest
    end

    it 'powers the vm on' do
      vm_mock = vim_vm_mock 'My VM', power_state: 'poweredOff'
      vm = VSphere::VirtualMachine.new vm_mock
      allow(vm_mock).to receive_message_chain :PowerOnVM_Task, :wait_for_completion
      vm.power_on
      expect(vm_mock).to have_received :PowerOnVM_Task
    end

    # It is important that the VM does not receive a PowerOnVM_Task if it is already powered on
    # This would otherwise throw an exception
    it 'does not power the vm if its already powered' do
      vm_mock = vim_vm_mock('my VM', power_state: 'poweredOn')
      vm = VSphere::VirtualMachine.new vm_mock
      allow(vm_mock).to receive_message_chain :PowerOnVM_Task, :wait_for_completion
      vm.power_on
      expect(vm_mock).not_to have_received(:PowerOnVM_Task)
    end

    it 'powers the vm off' do
      vm_mock = vim_vm_mock 'My VM', power_state: 'poweredOn'
      vm = VSphere::VirtualMachine.new vm_mock
      allow(vm_mock).to receive_message_chain :PowerOffVM_Task, :wait_for_completion
      vm.power_off
      expect(vm_mock).to have_received :PowerOffVM_Task
    end

    it 'does not power off the vm if its already powered' do
      vm_mock = vim_vm_mock 'My VM', power_state: 'poweredOff'
      vm = VSphere::VirtualMachine.new vm_mock
      allow(vm_mock).to receive_message_chain :PowerOffVM_Task, :wait_for_completion
      vm.power_off
      expect(vm_mock).not_to have_received :PowerOffVM_Task
    end
  end
end

# rubocop:enable RSpec/MessageChain
