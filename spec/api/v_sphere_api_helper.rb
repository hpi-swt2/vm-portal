# frozen_string_literal: true

require 'rails_helper'
require './app/api/v_sphere/folder'
require './app/api/v_sphere/virtual_machine'


# This file contains a few helper methods which allow for easy mocking of instances of the vSphere module
#
# To mock the entire VSphere API in one go, create new VSphere::Connection with
#   connection = v_sphere_connection_mock [<normal vms>], [<archived vms>], [<pending_archivation_vms>]
#   allow(VSphere::Connection).to receive(:instance).and_return connection
# After that you can use the VSphere module pretty much as normal
#
# You can use the v_sphere_vm_mock method to mock vms
#
# You can also use v_sphere_folder_mock method to mock folders in vSphere, note however that the mocks cannot create
# new subfolders and are generally pretty much limited to containing VMs or other folders
#
# Any methods that contain vim in their name are used to mock the internal objects of the vSphere API/rbvmomi and
# should not be used directly!

# We really want to be able to stub message chains in this file, because the API that is provided by vSphere
# has many messages that have to be chained which we want to mock.
# rubocop:disable RSpec/MessageChain

def extract_vim_vms(vms)
  vms.map do |each|
    if each.is_a? VSphere::VirtualMachine
      each.instance_eval { managed_folder_entry }
    else
      each
    end
  end
end

def extract_vim_folders(folders)
  folders.map do |each|
    if each.is_a? VSphere::Folder
      each.instance_eval { managed_folder_entry }
    else
      each
    end
  end
end

def vim_folder_mock(name, subfolders, vms) # rubocop:disable Metrics/AbcSize
  vms = extract_vim_vms vms
  subfolders = extract_vim_folders subfolders
  folder = double
  allow(folder).to receive(:name).and_return(name)
  allow(folder).to receive(:children).and_return(subfolders + vms)
  allow(folder).to receive(:is_a?).and_return false
  allow(folder).to receive(:is_a?).with(RbVmomi::VIM::Folder).and_return true
  folder
end

def v_sphere_folder_mock(name, subfolder, vms)
  VSphere::Folder.new vim_folder_mock(name, subfolder, vms)
end

def vim_vm_mock(name, power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled', boot_time: 'Yesterday') # rubocop:disable Metrics/AbcSize
  vm = double
  allow(vm).to receive(:name).and_return(name)
  allow(vm).to receive(:is_a?).and_return false
  allow(vm).to receive(:is_a?).with(RbVmomi::VIM::VirtualMachine).and_return true
  allow(vm).to receive_message_chain(:runtime, :powerState).and_return power_state
  allow(vm).to receive_message_chain(:guest, :toolsStatus).and_return vm_ware_tools
  allow(vm).to receive_message_chain(:runtime, :bootTime).and_return boot_time
  vm
end

def v_sphere_vm_mock(name, power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled', boot_time: 'Yesterday')
  VSphere::VirtualMachine.new vim_vm_mock(name,
                                          power_state: power_state,
                                          vm_ware_tools: vm_ware_tools,
                                          boot_time: boot_time)
end

def v_sphere_connection_mock(normal_vms, archived_vms, pending_archivation_vms)
  archived_vms_folder = v_sphere_folder_mock 'Archived VMs', [], archived_vms
  pending_archivation_vms_folder = v_sphere_folder_mock 'Pending archivings', [], pending_archivation_vms
  root_folder = v_sphere_folder_mock 'root', [archived_vms_folder, pending_archivation_vms_folder], normal_vms
  double_connection = double
  allow(double_connection).to receive(:root_folder).and_return root_folder
  double_connection
end

# rubocop:enable RSpec/MessageChain
