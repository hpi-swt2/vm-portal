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
  # rubocop:disable Metrics/ClassLength
  class VirtualMachine
    # instance creation
    def self.all
      root_folder.vms
    end

    def self.rest
      to_exclude = []
      pending_archivation.each { |each| to_exclude << each.name }
      archived.each { |each| to_exclude << each.name }
      pending_revivings.each { |each| to_exclude << each.name }

      all.reject { |each| to_exclude.include? each.name }
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
      vms = []
      GitHelper.open_repository PuppetParserHelper.puppet_script_path do
        files = Dir.entries(PuppetParserHelper.puppet_script_path)
        files.map! { |file| file[(6..file.length - 4)] }
        files.each do |vm_name|
          users = PuppetParserHelper.read_node_file(vm_name)
          users = users['admins'] + users['users'] | []
          vms += find_by_name(vm_name) if users.include? user
        end
      end
      vms
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
      @vm.summary.runtime.powerState == 'poweredOn'
    end

    def powered_off?
      @vm.summary.runtime.powerState == 'poweredOff'
    end

    # Power state
    def power_on
      @vm.PowerOnVM_Task.wait_for_completion unless powered_on?
    end

    def power_off
      @vm.PowerOffVM_Task.wait_for_completion unless powered_off?
    end

    def change_power_state
      if powered_on?
        power_off
      else
        power_on
      end
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
      ArchivationRequest.new(name: name).save
      move_into_correct_subfolder
    end

    def archivable?
      request = ArchivationRequest.find_by_name name
      if request
        request.can_be_executed?
      else
        true
      end
    end

    def set_archived
      if vm_ware_tools?
        shutdown_guest_os
      else
        power_off
      end

      move_into archived_folder
      archivation_request&.delete
      move_into_correct_subfolder
    end

    # Reviving
    def pending_reviving?
      pending_revivings_folder.vms.any? { |vm| vm.equal? self }
    end

    def set_pending_reviving
      move_into pending_revivings_folder
      move_into_correct_subfolder
    end

    def set_revived
      move_into root_folder
      archivation_request&.delete
      move_into_correct_subfolder
    end

    # Config methods
    # All the properties that HART saves internally
    def config
      @config ||= VirtualMachineConfig.find_by_name name
    end

    def ensure_config
      @config ||= VirtualMachineConfig.create(name: name)
    end

    def ip
      config&.ip || ''
    end

    def dns
      config&.dns || ''
    end

    # Folder Utilities
    def move_into(folder)
      folder.move_here self
    end

    def move_into_correct_subfolder
      target = target_subfolder
      move_into target unless target.vms(recursive: false).include? self
    end

    # Users
    def responsible_users
      config&.responsible_users || []
    end

    # this method should return all users, including the sudo users
    def users
      request&.users || []
    end

    def sudo_users
      if request
        request.sudo_users
      else
        []
      end
    end

    def belongs_to(user)
      users.include? user
    end

    # Information about the vm
    def boot_time
      @vm.runtime.bootTime
    end

    def summary
      @vm.summary
    end

    def guest_heartbeat_status
      @vm.guestHeartbeatStatus
    end

    def vmwaretools_installed?
      @vm.guest.toolsStatus != 'toolsNotInstalled'
    end

    def host_name
      @vm.summary.runtime.host.name
    end

    def active?
      !archived? && !pending_archivation? && !pending_reviving?
    end

    def status
      return :archived if archived?
      return :pending_archivation if pending_archivation?
      return :pending_reviving if pending_reviving?

      if powered_on?
        :online
      else
        :offline
      end
    end

    def users
      GitHelper.open_repository PuppetParserHelper.puppet_script_path do
        users = PuppetParserHelper.read_node_file(name)
        (users['admins'] + users['users']).uniq
      end
    end

    def commit_message(git_writer)
      if git_writer.added?
        'Add ' + name
      elsif git_writer.updated?
        'Update ' + name
      else
        ''
      end
    end

    def set_users(ids)
      begin
        GitHelper.open_repository(PuppetParserHelper.puppet_script_path) do |git_writer|
          all_users = PuppetParserHelper.read_node_file(name)
          sudo_users = all_users['admins']
          new_users = User.find_all_by_id(ids)
          puppetscript = Puppetscript.node_script(name, sudo_users, new_users)
          git_writer.write_file(name, puppetscript)
          message = commit_message(git_writer)
          git_writer.save(message)
        end
      rescue Git::GitExecuteError
        { alert: 'Could not push to git. Please check that your ssh key and environment variables are set.' }
      end
    end

    def sudo_users
      GitHelper.open_repository PuppetParserHelper.puppet_script_path do
        users = PuppetParserHelper.read_node_file(name)
        users['admins']
      end
    end

    def set_sudo_users(ids)
      begin
        GitHelper.open_repository(PuppetParserHelper.puppet_script_path) do |git_writer|
          all_users = PuppetParserHelper.read_node_file(name)
          users = all_users['users']
          new_sudo_users = User.find_all_by_id(ids)
          puppetscript = Puppetscript.node_script(name, new_sudo_users, users)
          git_writer.write_file(name, puppetscript)
          message = commit_message(git_writer)
          git_writer.save(message)
        end
      rescue Git::GitExecuteError
          { alert: 'Could not push to git. Please check that your ssh key and environment variables are set.' }
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

    def macs
      @vm.macs
    end

    def request
      Request.accepted.find { |each| name == each.name }
    end

    private

    def target_subfolder
      path = [] << case status
                   when :archived then archived_folder.name
                   when :pending_reviving then pending_revivings_folder.name
                   when :pending_archivation then pending_archivation_folder.name
                   else
                     'Active VMs'
                   end
      path << responsible_users.first.human_readable_identifier if responsible_users.first
      VSphere::Connection.instance.root_folder.ensure_subfolder_by_path path
    end

    def archivation_request
      ArchivationRequest.find_by_name(name)
    end

    def managed_folder_entry
      @vm
    end
  end
  # rubocop:enable Metrics/ClassLength
end
