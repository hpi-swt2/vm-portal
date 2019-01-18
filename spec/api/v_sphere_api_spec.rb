# frozen_string_literal: true

require 'rails_helper'

require './app/api/v_sphere/folder'
require './app/api/v_sphere/connection'

# We really want to be able to stub message chains in this Spec, because the API that is provided by vSphere
# has many messages that have to be chained which we want to mock.
# rubocop:disable RSpec/MessageChain
describe VSphere do
  def vim_folder_mock(name, subfolders, vms) # rubocop:disable Metrics/AbcSize
    folder = double
    allow(folder).to receive(:name).and_return(name)
    allow(folder).to receive(:children).and_return(subfolders + vms)
    allow(folder).to receive(:is_a?).and_return false
    allow(folder).to receive(:is_a?).with(RbVmomi::VIM::Folder).and_return true
    folder
  end

  def vim_vm_mock(name, power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled') # rubocop:disable Metrics/AbcSize
    vm = double
    allow(vm).to receive(:name).and_return(name)
    allow(vm).to receive(:is_a?).and_return false
    allow(vm).to receive(:is_a?).with(RbVmomi::VIM::VirtualMachine).and_return true
    allow(vm).to receive_message_chain(:runtime, :powerState).and_return power_state
    allow(vm).to receive_message_chain(:guest, :toolsStatus).and_return vm_ware_tools
    vm
  end

  let(:mock_archived_vms) do
    (1..5).map do |each|
      vim_vm_mock('Archived VM' + each.to_s, power_state: 'poweredOff')
    end
  end

  let(:mock_archived_vms_folder) do
    vim_folder_mock('Archived VMs', [], mock_archived_vms)
  end

  let(:mock_pending_archivings_vms) do
    (1..5).map do |each|
      vim_vm_mock('Pending Archiving VM' + each.to_s)
    end
  end

  let(:mock_pending_archivings_folder) do
    vim_folder_mock('Pending archivings', [], mock_pending_archivings_vms)
  end

  let(:mock_root_folder_vms) do
    (1..5).map do |each|
      vim_vm_mock('Root folder VM' + each.to_s, power_state: 'poweredOff')
    end
  end

  let(:mock_folder) do
    vim_folder_mock('vm', [mock_archived_vms_folder, mock_pending_archivings_folder], mock_root_folder_vms)
  end

  let(:root_folder) { VSphere::Folder.new(mock_folder) }

  describe VSphere::Folder do
    it 'finds all vms recursively' do
      vms = (mock_root_folder_vms + mock_archived_vms + mock_pending_archivings_vms).map { |each| VSphere::VirtualMachine.new each }
      expect(root_folder.vms(recursive: true)).to match_array vms
    end

    it 'finds all vms non-recursively' do
      vms = mock_root_folder_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(root_folder.vms(recursive: false)).to match_array vms
    end
  end

  describe VSphere::VirtualMachine do
    before do
      allow(VSphere::Connection.instance).to receive(:root_folder).and_return(root_folder)
    end

    it 'VirtualMachine.all finds all vms' do
      vms = (mock_root_folder_vms + mock_archived_vms + mock_pending_archivings_vms).map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.all).to match_array vms
    end

    it 'VirtualMachine.archived finds only archived VMs' do
      vms = mock_archived_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.archived).to match_array vms
    end

    it 'VirtualMachine.pending_archivation finds only vms that are pending archivation' do
      vms = mock_pending_archivings_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.pending_archivation).to match_array vms
    end

    it 'VirtualMachine.find_by_name finds all vms' do
      expect(VSphere::VirtualMachine.find_by_name('Archived VM2')).not_to be_nil
    end

    it 'does not have users if there is not fitting request' do
      expect(VSphere::VirtualMachine.find_by_name('Archived VM2').users).to be_empty
    end

    it 'has users if a fitting request exists' do
      request = FactoryBot.create :accepted_request
      request.users << FactoryBot.create(:user)
      vm = VSphere::VirtualMachine.new(vim_vm_mock(request.name))
      expect(vm.users).not_to be_empty
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
