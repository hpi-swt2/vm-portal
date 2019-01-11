# frozen_string_literal: true

require 'rbvmomi'
require 'singleton'
require 'virtual_machine'
# This class manages a connection to the VSphere backend
# For rbvmomi documentation see: https://github.com/vmware/rbvmomi/tree/master/examples
# For documentation of API objects have a look at this:
# https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html
class VSphereApi
  include Singleton

  API_SERVER_IP = '192.168.30.3'
  API_SERVER_USER = 'administrator@swt.local'
  API_SERVER_PASSWORD = 'Vcsaswt"2018'

  def get_vm(name)
    connect

    @vm_folder.find_vm(name)
  end

  def all_vms
    connect

    @vm_folder.vms
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
