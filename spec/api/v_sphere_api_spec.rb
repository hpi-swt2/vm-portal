# frozen_string_literal: true

require 'rails_helper'

require './app/api/v_sphere/folder'
require './app/api/v_sphere/connection'

describe VSphere do
  def vim_folder_mock(name, subfolders, vms) # rubocop:disable Metrics/AbcSize
    folder = double
    allow(folder).to receive(:name).and_return(name)
    allow(folder).to receive(:children).and_return(subfolders + vms)
    allow(folder).to receive(:is_a?).and_return false
    allow(folder).to receive(:is_a?).with(RbVmomi::VIM::Folder).and_return true
    folder
  end

  def vim_vm_mock(name) # rubocop:disable Metrics/AbcSize
    vm = double
    allow(vm).to receive(:name).and_return(name)
    allow(vm).to receive(:is_a?).and_return false
    allow(vm).to receive(:is_a?).with(RbVmomi::VIM::VirtualMachine).and_return true
    vm
  end

  let(:mock_archived_vms) do
    vms = []
    (1..5).each do |each|
      vms << vim_vm_mock('Archived VM' + each.to_s)
    end
    vms
  end

  let(:mock_archived_vms_folder) do
    vim_folder_mock('Archived VMs', [], mock_archived_vms)
  end

  let(:mock_root_folder_vms) do
    vms = []
    (1..5).each do |each|
      vms << vim_vm_mock('Root folder VM' + each.to_s)
    end
    vms
  end

  let(:mock_folder) do
    vim_folder_mock('vm', [mock_archived_vms_folder], mock_root_folder_vms)
  end

  let(:root_folder) { VSphere::Folder.new(mock_folder) }

  describe VSphere::Folder do
    it 'finds all vms recursively' do
      vms = (mock_root_folder_vms + mock_archived_vms).map { |each| VSphere::VirtualMachine.new each }
      expect(root_folder.vms(recursive: true)).to match_array vms
    end

    it 'finds all vms non-recursively' do
      vms = mock_root_folder_vms.map{|each| VSphere::VirtualMachine.new each}
      expect(root_folder.vms(recursive: false)).to match_array vms
    end
  end

  describe VSphere::VirtualMachine do
    before do
      allow(VSphere::Connection.instance).to receive(:root_folder).and_return(root_folder)
    end

    it 'VirtualMachine.all finds even archived VMs' do
      vms = (mock_root_folder_vms + mock_archived_vms).map {|each| VSphere::VirtualMachine.new each}
      expect(VSphere::VirtualMachine.all).to match_array vms
    end

    it 'VirtualMachine.archived finds only archived VMs' do
      vms = mock_archived_vms.map { |each| VSphere::VirtualMachine.new each }
      expect(VSphere::VirtualMachine.archived).to match_array vms
    end

    it 'knows that it is not archived' do
      non_archived_vms = mock_root_folder_vms.map{ |each| VSphere::VirtualMachine.new each}
      non_archived_vms.each { |each| expect(each.archived?).to be false }
    end

    it 'knows that it is archived' do
      archived_vms = mock_archived_vms.map { |each| VSphere::VirtualMachine.new each }
      archived_vms.each { |each| expect(each.archived?).to be true }
    end

    it 'moves into the correct folder when it is archived' do
      vm = VSphere::VirtualMachine.new mock_archived_vms.first
      allow(mock_archived_vms_folder).to receive_message_chain(:MoveIntoFolder_Task, :wait_for_completion)
      vm.set_archived
      expect(mock_archived_vms_folder).to have_received(:MoveIntoFolder_Task)
    end
  end
end
