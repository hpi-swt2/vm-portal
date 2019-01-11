# frozen_string_literal: true

require 'rbvmomi'
require 'singleton'
require 'virtual_machine'
require 'folder'

# This module is responsible for communicating with vSphere
# It creates wrapper objects for Virtual Machines and Folders which allow easy access to all tasks and information
# rbvmomi methods or other underlying vSphere API methods should NOT be called directly outside of this module!
# If you need additional vSphere features, implement them as methods on classes of the VSphere module
module VSphere
  # This class manages a connection to the VSphere backend
  # For rbvmomi documentation see: https://github.com/vmware/rbvmomi/tree/master/examples
  # For documentation of API objects have a look at this:
  # https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html
  class Connection
    include Singleton

    API_SERVER_IP = '192.168.30.3'
    API_SERVER_USER = 'administrator@swt.local'
    API_SERVER_PASSWORD = 'Vcsaswt"2018'

    def create_vm(cpu, ram, capacity, name)
      connect
      vm_config = creation_config(cpu, ram, capacity, name)
      vm = @vm_folder.CreateVM_Task(config: vm_config, pool: @resource_pool).wait_for_completion
      VSphere::VirtualMachine.new(vm)
    end

    def root_folder
      connect

      @vm_folder
    end

    private

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
      @vm_folder = VSphere::Folder.new(@dc.vmFolder)
      @cluster_folder = @dc.hostFolder
      @clusters = extract_clusters(@cluster_folder).flatten
      @resource_pool = @clusters.first.resourcePool
    end

    def extract_clusters(element)
      if element.class == RbVmomi::VIM::Folder
        clusters = []
        element.children.each do |child|
          clusters << extract_clusters(child)
        end
        clusters
      else
        [element]
      end
    end
  end
end
