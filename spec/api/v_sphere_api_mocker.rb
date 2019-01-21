# frozen_string_literal: true

require 'rails_helper'
require './app/api/v_sphere/folder'
require './app/api/v_sphere/virtual_machine'
require './app/api/v_sphere/cluster'
require './app/api/v_sphere/host'

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

def extract_vim_objects(collection)
  collection.map do |each|
    if [VSphere::Cluster, VSphere::Folder, VSphere::VirtualMachine].include? each.class
      each.instance_exec { managed_folder_entry }
    else
      each
    end
  end
end

def vim_folder_mock(name, subfolders, vms, clusters) # rubocop:disable Metrics/AbcSize
  children = subfolders + vms + clusters
  children = extract_vim_objects children
  folder = double
  allow(folder).to receive(:name).and_return(name)
  allow(folder).to receive(:children).and_return(children)
  allow(folder).to receive(:is_a?).and_return false
  allow(folder).to receive(:is_a?).with(RbVmomi::VIM::Folder).and_return true
  folder
end

def v_sphere_folder_mock(name, subfolders: [], vms: [], clusters: [])
  VSphere::Folder.new vim_folder_mock(name, subfolders, vms, clusters)
end

def vim_vm_summary_mock
  summary_double = double
  allow(summary_double).to receive_message_chain(:storage, :committed).and_return(100)
  allow(summary_double).to receive_message_chain(:storage, :uncommitted).and_return(100)
  allow(summary_double).to receive_message_chain(:config, :guestId).and_return('Win10')
  allow(summary_double).to receive_message_chain(:config, :guestFullName).and_return('Win10 EE')
  allow(summary_double).to receive_message_chain(:guest, :ipAddress).and_return('0.0.0.0')
  allow(summary_double).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(50)
  allow(summary_double).to receive_message_chain(:config, :cpuReservation).and_return(100)
  allow(summary_double).to receive_message_chain(:quickStats, :guestMemoryUsage).and_return(1024)
  allow(summary_double).to receive_message_chain(:config, :memorySizeMB).and_return(2024)
  allow(summary_double).to receive_message_chain(:config, :numCpu).and_return(2)
  allow(summary_double).to receive_message_chain(:runtime, :powerState).and_return('poweredOn')
  allow(summary_double).to receive_message_chain(:runtime, :host, :name).and_return 'aHost'
  summary_double
end

# rubocop:disable Metrics/AbcSize
def vim_vm_mock(
    name,
    power_state: 'poweredOn',
    vm_ware_tools: 'toolsNotInstalled',
    boot_time: 'Yesterday',
    guest_heartbeat_status: 'green'
)
  vm = double
  allow(vm).to receive(:name).and_return(name)
  allow(vm).to receive(:is_a?).and_return false
  allow(vm).to receive(:is_a?).with(RbVmomi::VIM::VirtualMachine).and_return true
  allow(vm).to receive_message_chain(:runtime, :powerState).and_return power_state
  allow(vm).to receive_message_chain(:runtime, :bootTime).and_return boot_time
  allow(vm).to receive(:guestHeartbeatStatus).and_return guest_heartbeat_status
  allow(vm).to receive(:summary).and_return vim_vm_summary_mock
  allow(vm).to receive_message_chain(:guest, :toolsStatus).and_return vm_ware_tools
  vm
end
# rubocop:enable Metrics/AbcSize

def v_sphere_vm_mock(
    name,
    power_state: 'poweredOn',
    vm_ware_tools: 'toolsNotInstalled',
    boot_time: 'Yesterday',
    guest_heartbeat_status: 'green'
)
  VSphere::VirtualMachine.new vim_vm_mock(name,
                                          power_state: power_state,
                                          vm_ware_tools: vm_ware_tools,
                                          boot_time: boot_time,
                                          guest_heartbeat_status: guest_heartbeat_status,
                              )
end

def vim_host_mock(name)
  host = double
  allow(host).to receive(:name).and_return name
  host
end

def v_sphere_host_mock(name)
  VSphere::Host.new vim_host_mock(name)
end

# rubocop:disable Metrics/AbcSize
def vim_cluster_mock(name, hosts)
  hosts = extract_vim_objects hosts
  cluster = double
  allow(cluster).to receive(:is_a?).and_return false
  allow(cluster).to receive(:is_a?).with(RbVmomi::VIM::ComputeResource).and_return true
  allow(cluster).to receive(:host).and_return hosts
  allow(cluster).to receive(:name).and_return name
  cluster
end
# rubocop:enable Metrics/AbcSize

def v_sphere_cluster_mock(name, hosts)
  VSphere::Cluster.new vim_cluster_mock(name, hosts)
end

def v_sphere_connection_mock(normal_vms, archived_vms, pending_archivation_vms, pending_revivings_vms, clusters)
  archived_vms_folder = v_sphere_folder_mock 'Archived VMs', vms: archived_vms
  pending_archivation_vms_folder = v_sphere_folder_mock 'Pending archivings', vms: pending_archivation_vms
  pending_reviving_vms_folder = v_sphere_folder_mock 'Pending revivings', vms: pending_revivings_vms
  root_folder = v_sphere_folder_mock 'root', subfolders: [archived_vms_folder, pending_archivation_vms_folder,
                                                          pending_reviving_vms_folder], vms: normal_vms
  clusters_folder = v_sphere_folder_mock 'clusters', clusters: clusters
  double_connection = double
  allow(double_connection).to receive(:root_folder).and_return root_folder
  allow(double_connection).to receive(:clusters_folder).and_return clusters_folder
  double_connection
end

# rubocop:enable RSpec/MessageChain
