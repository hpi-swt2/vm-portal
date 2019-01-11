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

    find_vm_in(@vm_folder, name)
  end

  def all_vms
    connect

    all_vms_in(@vm_folder)
  end

  def all_vms_in(folder)
    vms = folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::VirtualMachine }.map do |each|
      VirtualMachine.new each
    end

    vms.append(all_folders_in(folder).flat_map { |each| all_vms_in(each) })
    vms
  end

  def ensure_folder(folder_name)
    connect
    folder = @vm_folder.find folder_name, RbVmomi::VIM::Folder
    folder || @vm_folder.CreateFolder(name: folder_name)
  end

  private


  def all_folders_in(folder)
    folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::Folder }
  end

  def find_vm_in(folder, name)
    if (vm = folder.traverse(name, RbVmomi::VIM::VirtualMachine))
      VirtualMachine.new vm
    else
      all_folders_in(folder).each do |each|
        if (vm = find_vm_in(each, name))
          return VirtualMachine.new vm
        end
      end
      nil
    end
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
