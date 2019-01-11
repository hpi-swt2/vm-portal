# frozen_string_literal: true

require 'rbvmomi'
require 'v_sphere_api'

# This class wraps a rbvmomi Folder and provides easy access to common operations
module VSphere
  class Folder
    def initialize(rbvmomi_folder)
      @folder = rbvmomi_folder
    end

    def sub_folders
      @folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::Folder }.map do |each|
        Folder.new(each)
      end
    end

    def vms(recursive: true)
      vms = @folder.children.select { |folder_entry| folder_entry.is_a? RbVmomi::VIM::VirtualMachine }.map do |each|
        VSphere::VirtualMachine.new each
      end

      vms.append(@folder.sub_folders.flat_map(&:vms)) if recursive
      vms
    end

    # name must be the name of the vm as a string
    def find_vm(name, recursive: true)
      vms(recursive).find { |each| each.name = name }
    end

    # Ensure that a subfolder exists and return it
    # folder_name is a string with the name of the subfolder
    def ensure_subfolder(folder_name)
      connect
      folder = @folder.find folder_name, RbVmomi::VIM::Folder
      VSphere::Folder.new(folder || @folder.CreateFolder(name: folder_name))
    end

    def move_here(folder_entry)
      managed_entry = folder_entry.instance_exec { managed_folder_entry }
      @folder.MoveIntoFolder_Task(list: [managed_entry]).wait_for_completion
    end

    private

    def managed_folder_entry
      @folder
    end
  end
end
