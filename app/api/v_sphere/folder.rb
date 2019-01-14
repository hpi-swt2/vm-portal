# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection.rb'

# This class wraps a rbvmomi Folder and provides easy access to common operations
module VSphere
  class Folder
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
      folder = subfolders.find { |each| each.name == folder_name }
      folder || VSphere::Folder.new(@folder.CreateFolder(name: folder_name))
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
