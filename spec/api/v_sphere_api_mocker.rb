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

# Disable AbcSize and MethodLength as mocking is not really complex, but increases these 2 metrics very fast
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

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
  allow(folder).to receive(:name).and_return name
  allow(folder).to receive(:parent).and_return nil
  allow(folder).to receive(:children).and_return children
  allow(folder).to receive(:is_a?).and_return false
  allow(folder).to receive(:is_a?).with(RbVmomi::VIM::Folder).and_return true
  allow(folder).to receive_message_chain(:MoveIntoFolder_Task, :wait_for_completion)
  allow(folder).to receive(:CreateVM_Task) do |*args|
    task = double
    allow(task).to receive(:wait_for_completion) do
      vm = vim_vm_mock(args.first[:config][:name])
      children << vm
      vm
    end
    task
  end

  allow(folder).to receive(:CreateFolder) do |subfolder_name|
    folder = vim_folder_mock(subfolder_name, [], [], [])
    children << folder
    folder
  end
  folder
end

def v_sphere_folder_mock(name, subfolders: [], vms: [], clusters: [])
  VSphere::Folder.new vim_folder_mock(name, subfolders, vms, clusters)
end

def vim_vm_summary_mock(power_state: 'poweredOn')
  summary_double = double
  allow(summary_double).to receive_message_chain(:storage, :committed).and_return(100)
  allow(summary_double).to receive_message_chain(:storage, :uncommitted).and_return(100)
  allow(summary_double).to receive_message_chain(:config, :guestId).and_return('Win10')
  allow(summary_double).to receive_message_chain(:config, :guestFullName).and_return('Win10 EE')
  allow(summary_double).to receive_message_chain(:guest, :ipAddress).and_return('0.0.0.0')
  allow(summary_double).to receive_message_chain(:quickStats, :overallCpuDemand).and_return(100)
  allow(summary_double).to receive_message_chain(:runtime, :maxCpuUsage).and_return(500)
  allow(summary_double).to receive_message_chain(:quickStats, :guestMemoryUsage).and_return(1024)
  allow(summary_double).to receive_message_chain(:config, :memorySizeMB).and_return(2024)
  allow(summary_double).to receive_message_chain(:config, :numCpu).and_return(2)
  allow(summary_double).to receive_message_chain(:runtime, :powerState).and_return(power_state)
  allow(summary_double).to receive_message_chain(:runtime, :host, :name).and_return 'aHost'
  summary_double
end

def vim_disks_mock
  disk = double
  allow(disk).to receive(:capacityInKB).and_return(100 * (1024**2))
  [disk]
end

def vim_guest_mock(tools_status: 'toolsNotInstalled')
  guest = double
  allow(guest).to receive(:toolsStatus).and_return tools_status
  allow(guest).to receive(:disk).and_return [] # vSphere will actually return an empty array if wm_ware_tools are not installed
  guest
end

def vim_vm_mock(
    name,
    power_state: 'poweredOn',
    vm_ware_tools: 'toolsNotInstalled',
    boot_time: 'Yesterday',
    guest_heartbeat_status: 'green',
    macs: [['Network Adapter 1', 'My Mac address']]
  )
  vm = double
  allow(vm).to receive(:name).and_return(name)
  allow(vm).to receive(:guestHeartbeatStatus).and_return(guest_heartbeat_status)
  allow(vm).to receive(:is_a?).and_return false
  allow(vm).to receive(:is_a?).with(RbVmomi::VIM::VirtualMachine).and_return true
  allow(vm).to receive_message_chain(:runtime, :powerState).and_return power_state
  allow(vm).to receive_message_chain(:runtime, :bootTime).and_return boot_time
  allow(vm).to receive(:guest).and_return vim_guest_mock(tools_status: vm_ware_tools)
  allow(vm).to receive(:macs).and_return macs
  allow(vm).to receive(:boot_time). and_return 0
  allow(vm).to receive(:summary).and_return vim_vm_summary_mock(power_state: power_state)
  allow(vm).to receive(:disks).and_return vim_disks_mock

  vm
end

def v_sphere_vm_mock(name, power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled', boot_time: Time.now - 60 * 60 * 24)
  VSphere::VirtualMachine.new vim_vm_mock(name,
                                          power_state: power_state,
                                          vm_ware_tools: vm_ware_tools,
                                          boot_time: boot_time)
end

def vim_host_summary_mock
  summary = double
  allow(summary).to receive_message_chain(:runtime, :powerState)
  allow(summary).to receive_message_chain(:config, :product, :osType).and_return('someOS')
  allow(summary).to receive_message_chain(:config, :product, :fullName).and_return(['someProduct'])
  allow(summary).to receive_message_chain(:hardware, :cpuModel).and_return('someModel')
  allow(summary).to receive_message_chain(:hardware, :numCpuCores).and_return(4)
  allow(summary).to receive_message_chain(:hardware, :numCpuThreads).and_return(4)
  allow(summary).to receive_message_chain(:hardware, :cpuMhz).and_return(1000)
  allow(summary).to receive_message_chain(:hardware, :memorySize).and_return(1000 * 1024**3) # in bytes
  allow(summary).to receive_message_chain(:quickStats, :overallMemoryUsage).and_return(0)
  allow(summary).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(0)
  summary
end

def vim_host_mock(name)
  host = double
  allow(host).to receive(:name).and_return name
  allow(host).to receive_message_chain(:runtime, :bootTime)
  allow(host).to receive(:connection_state).and_return('connected')
  allow(host).to receive(:boot_time).and_return('someRuntime')
  allow(host).to receive_message_chain(:runtime, :connectionState)
  allow(host).to receive_message_chain(:config, :product, :osType)
  allow(host).to receive_message_chain(:config, :product, :fullName)
  allow(host).to receive_message_chain(:hardware, :cpuModel)
  allow(host).to receive_message_chain(:quickStats, :overallMemoryUsage).and_return(0)
  allow(host).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(0)
  allow(host).to receive_message_chain(:hardware, :systemInfo, :vendor).and_return('someVendor')
  allow(host).to receive_message_chain(:hardware, :systemInfo, :model).and_return(name)
  allow(host).to receive(:vm).and_return([v_sphere_vm_mock('My insanely cool vm',
                                                           power_state: 'poweredOn',
                                                           vm_ware_tools: 'toolsInstalled')])

  allow(host).to receive(:summary).and_return vim_host_summary_mock

  datastore = double
  allow(datastore).to receive_message_chain(:summary, :capacity).and_return(1000 * 1024**3) # in bytes
  allow(datastore).to receive_message_chain(:summary, :freeSpace).and_return(1000 * 1024**3) # in bytes
  allow(host).to receive(:datastore).and_return([datastore])

  host
end

def v_sphere_host_mock(name)
  VSphere::Host.new vim_host_mock(name)
end

def vim_cluster_mock(name, hosts)
  hosts = extract_vim_objects hosts
  cluster = double
  allow(cluster).to receive(:is_a?).and_return false
  allow(cluster).to receive(:is_a?).with(RbVmomi::VIM::ComputeResource).and_return true
  allow(cluster).to receive(:host).and_return hosts
  allow(cluster).to receive(:name).and_return name
  allow(cluster).to receive(:resourcePool).and_return nil
  network = double
  allow(network).to receive(:name).and_return 'MyNetwork'
  allow(cluster).to receive(:network).and_return [network]
  cluster
end

def v_sphere_cluster_mock(name, hosts)
  VSphere::Cluster.new vim_cluster_mock(name, hosts)
end

def v_sphere_connection_mock(
    normal_vms: [],
    archived_vms: [],
    pending_archivation_vms: [],
    pending_revivings_vms: [],
    clusters: []
  )
  archived_vms_folder = v_sphere_folder_mock 'Archived VMs', vms: archived_vms
  pending_archivation_vms_folder = v_sphere_folder_mock 'Pending archivings', vms: pending_archivation_vms
  pending_reviving_vms_folder = v_sphere_folder_mock 'Pending revivings', vms: pending_revivings_vms
  active_vms_folder = v_sphere_folder_mock 'Active VMs', vms: normal_vms
  root_folder = v_sphere_folder_mock 'root', subfolders: [archived_vms_folder, pending_archivation_vms_folder,
                                                          pending_reviving_vms_folder, active_vms_folder]
  clusters_folder = v_sphere_folder_mock 'clusters', clusters: clusters
  double_connection = double
  allow(double_connection).to receive(:root_folder).and_return root_folder
  allow(double_connection).to receive(:clusters_folder).and_return clusters_folder
  allow(double_connection).to receive(:configured?).and_return true
  double_connection
end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
# rubocop:enable RSpec/MessageChain
