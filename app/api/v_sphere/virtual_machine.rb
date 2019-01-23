# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection'

def root_folder
  VSphere::Connection.instance.root_folder
end

def ensure_root_subfolder(name)
  root_folder.ensure_subfolder(name)
end

def archived_folder
  ensure_root_subfolder('Archived VMs')
end

def pending_archivation_folder
  ensure_root_subfolder('Pending archivings')
end

def pending_revivings_folder
  ensure_root_subfolder('Pending revivings')
end

# This class wraps a rbvmomi Virtual Machine and provides easy access to important information
module VSphere
  class VirtualMachine
    # instance creation
    def self.all
      root_folder.vms
    end

    def self.rest
      all - pending_archivation - archived - pending_revivings
    end

    def self.pending_archivation
      pending_archivation_folder.vms
    end

    def self.archived
      archived_folder.vms
    end

    def self.pending_revivings
      pending_revivings_folder.vms
    end

    def self.find_by_name(name)
      root_folder.find_vm(name)
    end

    def self.user_vms(user)
      requests = user.requests.accepted
      requests.map { |request| find_by_name(request.name) }.compact
    end

    def initialize(rbvmomi_vm)
      @vm = rbvmomi_vm
    end

    def name
      @vm.name
    end

    # Guest OS communication
    def vm_ware_tools?
      @vm.guest.toolsStatus != 'toolsNotInstalled'
    end

    def suspend_vm
      @vm.SuspendVM_Task.wait_for_completion if powered_on?
    end

    def reset_vm
      @vm.ResetVM_Task.wait_for_completion if powered_on?
    end

    def shutdown_guest_os
      @vm.ShutdownGuest.wait_for_completion if powered_on?
    end

    def reboot_guest_os
      @vm.RebootGuest.wait_for_completion
    end

    # Power state testing
    # We do not provide a power_state? method which just returns a boolean, because vSphere can internally handle
    # more than just two power states and we might later need to respond to more states than just two
    def powered_on?
      @vm.runtime.powerState == 'poweredOn'
    end

    def powered_off?
      @vm.runtime.powerState == 'poweredOff'
    end

    # Power state
    def power_on
      @vm.PowerOnVM_Task.wait_for_completion unless powered_on?
    end

    def power_off
      @vm.PowerOffVM_Task.wait_for_completion unless powered_off?
    end

    # Archiving
    # The archiving process actually just moves the VM into different folders to communicate their state
    # Therefore we can check those folders to receive the current VM state
    # Archiving then moves a VM into the corresponding folder
    def pending_archivation?
      pending_archivation_folder.vms.any? { |vm| vm.equal? self }
    end

    def archived?
      archived_folder.vms.any? { |vm| vm.equal? self }
    end

    def set_pending_archivation
      move_into pending_archivation_folder
    end

    def set_archived
      if vm_ware_tools?
        shutdown_guest_os
      else
        power_off
      end

      move_into archived_folder
    end

    # Reviving
    def pending_reviving?
      pending_revivings_folder.vms.any? { |vm| vm.equal? self }
    end

    def set_pending_reviving
      move_into pending_revivings_folder
    end

    def set_revived
      move_into root_folder
    end

    # Utilities
    def move_into(folder)
      folder.move_here self
    end

    def boot_time
      @vm.runtime.bootTime
    end

    def users
      request = Request.accepted.find { |each| name == each.name }
      if request
        request.users
      else
        []
      end
    end

    def belongs_to(user)
      users.include? user
    end

    # We cannot use Object identity to check if to Virtual Machine objects are equal
    # because they are created on demand and to Virtual Machine objects can wrap the same vSphere VM.
    # Therefore we must use another method of comparing equality.
    # vSphere enforces that all VM names must be distinct, so we can use this to check for equality
    def equal?(other)
      (other.is_a? VSphere::VirtualMachine) && other.name == name
    end

    def ==(other)
      equal? other
    end

    private

    def managed_folder_entry
      @vm
    end
  end
end
