# frozen_string_literal: true

require 'rbvmomi'
require 'singleton'
# This class manages a connection to the VSphere backend
# For rbvmomi documentation see: https://github.com/vmware/rbvmomi/tree/master/examples
# For documentation of API objects have a look at this:
# https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html
class VmApi
  include Singleton
  API_SERVER_IP = '192.168.30.3'
  API_SERVER_USER = 'administrator@swt.local'
  API_SERVER_PASSWORD = 'Vcsaswt"2018'

  def create_vm(cpu, ram, capacity, name)
    connect
    vm_config = creation_config(cpu, ram, capacity, name)
    @vm_folder.CreateVM_Task(config: vm_config, pool: @resource_pool).wait_for_completion
  end

  def all_vms
    connect
    all_vms_in(@vm_folder).map do |vm|
      { name: vm.name,
        state: (vm.runtime.powerState == 'poweredOn'),
        boot_time: vm.runtime.bootTime,
        vmwaretools: (vm.guest.toolsStatus != 'toolsNotInstalled')}
    end
  end

  def all_archived_vms
    connect
    all_vms_in(all_vm_folders.detect { |folder| folder.name == 'Archived VMs' })
  end

  def all_clusters
    connect
    @clusters.map do |cluster|
      { name: cluster.name, stats: cluster.stats, cores: cluster.summary[:numCpuCores], threads: cluster.summary[:numCpuThreads] }
    end
  end

  def all_hosts
    connect
    @hosts = Array.new([])
    @clusters.map do |cluster|
      cluster.host.map do |host|
        vms = {}
        host.vm.map do |vm|
          state = vm.runtime.powerState == 'poweredOn'
          vms[vm.name] = state
        end
        @hosts << { name: host.name,
                    vms: vms,
                    model: host.hardware.systemInfo.model,
                    vendor: host.hardware.systemInfo.vendor,
                    bootTime: host.runtime.bootTime,
                    connectionState: host.runtime.connectionState,
                    summary: host.summary }
      end
    end
    @hosts
  end

  def get_vm(name)
    connect
    if (vm = find_vm(name))
      { name: vm.name,
        state: (vm.runtime.powerState == 'poweredOn'),
        boot_time: vm.runtime.bootTime,
        host: vm.summary.runtime.host.name,
        guestHeartbeatStatus: vm.guestHeartbeatStatus,
        summary: vm.summary,
        vmwaretools: (vm.guest.toolsStatus != 'toolsNotInstalled')
      }
    end
  end

  def get_host(name)
    all_hosts
    @hosts.each do |host|
      return host if host[:name] == name
    end
    nil
  end

  def delete_vm(name)
    connect
    vm = find_vm(name)
    vm.PowerOffVM_Task.wait_for_completion if vm.runtime.powerState == 'poweredOn'
    vm.Destroy_Task.wait_for_completion
  end

  def change_power_state(name, state)
    connect
    vm = find_vm name
    if state
      vm.PowerOffVM_Task.wait_for_completion
    else
      vm.PowerOnVM_Task.wait_for_completion
    end
  end

  def suspend_vm(name)
    connect
    vm = find_vm name
    vm.SuspendVM_Task.wait_for_completion
  end

  def reset_vm(name)
    connect
    vm = find_vm name
    vm.ResetVM_Task.wait_for_completion
  end

  def shutdown_guest_os(name)
    connect
    vm = find_vm name
    vm.ShutdownGuest.wait_for_completion
  end

  def reboot_guest_os(name)
    connect
    vm = find_vm name
    vm.RebootGuest.wait_for_completion
  end

  private

  def all_vm_folders
    @vm_folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::Folder }
  end

  def all_vms_in(folder)
    folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::VirtualMachine }
  end

  def find_vm(name)
    @vm_folder.traverse(name, RbVmomi::VIM::VirtualMachine)
  end

  def creation_config(cpu, ram, capacity, name) # rubocop:disable Metrics/MethodLength
    {
      name: name,
      guestId: 'otherGuest',
      files: { vmPathName: '[Datastore]' },
      numCPUs: cpu,
      memoryMB: ram,
      deviceChange: [
        {
          operation: :add,
          device: RbVmomi::VIM.VirtualLsiLogicController(
            key: 1000,
            busNumber: 0,
            sharedBus: :noSharing
          )
        }, {
          operation: :add,
          fileOperation: :create,
          device: RbVmomi::VIM.VirtualDisk(
            key: 0,
            backing: RbVmomi::VIM.VirtualDiskFlatVer2BackingInfo(
              fileName: '[Datastore]',
              diskMode: :persistent,
              thinProvisioned: true
            ),
            controllerKey: 1000,
            unitNumber: 0,
            capacityInKB: capacity
          )
        }, {
          operation: :add,
          device: RbVmomi::VIM.VirtualE1000(
            key: 0,
            deviceInfo: {
              label: 'Network Adapter 1',
              summary: 'VM Network'
            },
            backing: RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(
              deviceName: 'VM Network'
            ),
            addressType: 'generated'
          )
        }
      ],
      extraConfig: [
        {
          key: 'bios.bootOrder',
          value: 'ethernet0'
        }
      ]
    }
  end

  def connect
    @vim = RbVmomi::VIM.connect(host: API_SERVER_IP, user: API_SERVER_USER, password: API_SERVER_PASSWORD, insecure: true)
    @dc = @vim.serviceInstance.find_datacenter('Datacenter') || raise('datacenter not found')
    @vm_folder = @dc.vmFolder
    @cluster_folder = @dc.hostFolder
    @clusters = extract_clusters(@cluster_folder).flatten
    @vms = @vm_folder.children
    @resource_pool = @clusters.first.resourcePool
  end

  def extract_clusters(element)
    if element.class == RbVmomi::VIM::Folder
      a = []
      element.children.each do |child|
        a << extract_clusters(child)
      end
      a
    else
      [element]
    end
  end
end
