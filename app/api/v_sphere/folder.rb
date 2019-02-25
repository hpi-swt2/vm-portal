# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection'
require_relative 'cluster'

# This class wraps a rbvmomi Folder and provides easy access to common operations
module VSphere
  class Folder
    # this limit is enforced by the vSphere API when creating a folder
    # see: https://code.vmware.com/apis/196/vsphere#/doc/vim.Folder.html#createFolder
    VSPHERE_FOLDER_NAME_CHARACTER_LIMIT = 79

    def initialize(rbvmomi_folder)
      @folder = rbvmomi_folder
    end

    def subfolders
      @folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::Folder }.map do |each|
        Folder.new each
      end
    end

    def vms(recursive: true)
      vms = @folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::VirtualMachine }.map do |each|
        VSphere::VirtualMachine.new each
      end

      vms += subfolders.flat_map(&:vms) if recursive
      vms
    end

    def clusters(recursive: true)
      clusters = @folder.children.select do |folder_entry|
        folder_entry.is_a?(RbVmomi::VIM::ClusterComputeResource) || folder_entry.is_a?(RbVmomi::VIM::ComputeResource)
      end
      clusters = clusters.map { |each| VSphere::Cluster.new each }

      clusters += subfolders.flat_map(&:clusters) if recursive
      clusters
    end

    # name must be the name of the vm as a string
    def find_vm(name, recursive: true)
      vms(recursive: recursive).find { |each| each.name == name }
    end

    def name
      @folder.name
    end

    # Ensure that a subfolder exists and return it
    # folder_name is a string with the name of the subfolder
    def ensure_subfolder(folder_name)
      subfolder = subfolders.find { |each| each.name == folder_name }
      subfolder || VSphere::Folder.new(@folder.CreateFolder(name: folder_name))
    end

    # Ensure that the path relative to this folder is a valid folder and return it
    # The path is an array of strings
    def ensure_subfolder_by_path(path)
      return self if path.empty?

      ensure_subfolder(path.first).ensure_subfolder_by_path(path[1..-1])
    end

    def move_here(folder_entry)
      managed_entry = folder_entry.instance_exec { managed_folder_entry }
      @folder.MoveIntoFolder_Task(list: [managed_entry]).wait_for_completion
    end

    def create_vm(cpu, ram, capacity, name, cluster)
      vm_config = creation_config(cpu, ram, capacity, name)
      vm = @folder.CreateVM_Task(config: vm_config, pool: cluster.resource_pool).wait_for_completion
      VSphere::VirtualMachine.new vm
    end

    private

    def managed_folder_entry
      @folder
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
  end
end
