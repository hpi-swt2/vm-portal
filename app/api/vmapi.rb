# frozen_string_literal: true

require 'rbvmomi'
# This class manages a connection to the VSphere backend
# For rbvmomi documentation see: https://github.com/vmware/rbvmomi/tree/master/examples
# For documentation of API objects have a look at this:
# https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html
class VmApi
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
    @vm_folder.children.map do |vm|
      { name: vm.name, state: (vm.runtime.powerState == 'poweredOn'), boot_time: vm.runtime.bootTime }
    end
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
      vm.PowerOnVM_Task.wait_for_completion
    else
      vm.PowerOffVM_Task.wait_for_completion
    end
  end

  private

  def find_vm(name)
    @vm_folder.traverse(name, RbVmomi:: VIM::VirtualMachine)
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
    @hosts = @dc.hostFolder.children
    @resource_pool = @hosts.first.resourcePool
  end
end
