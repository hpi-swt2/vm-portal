# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection'

def root_folder
  VSphere::Connection.instance.root_folder
end

def ensure_root_subfolder(name)
  root_folder&.ensure_subfolder(name)
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
      root_folder&.vms || []
    end

    def self.rest
      to_exclude = []
      pending_archivation.each { |each| to_exclude << each.name }
      archived.each { |each| to_exclude << each.name }
      pending_revivings.each { |each| to_exclude << each.name }

      all.reject { |each| to_exclude.include? each.name }
    end

    def self.pending_archivation
      pending_archivation_folder&.vms || []
    end

    def self.archived
      archived_folder&.vms || []
    end

    def self.pending_revivings
      pending_revivings_folder&.vms || []
    end

    def self.find_by_name(name)
      root_folder&.find_vm(name)
    end

    def self.prepare_vm_names
      nodes_path = Puppetscript.nodes_path
      return [] unless File.exist?(nodes_path)

      files = Dir.entries(nodes_path)
      files.map! { |file| file[(5..file.length - 4)] }
      files.reject!(&:nil?)
      files
    end

    def self.includes_user?(vm_name, user)
      users = Puppetscript.read_node_file(vm_name)
      users = users[:admins] + users[:users] | []
      users.include? user
    end

    def self.user_vms(user)
      vms = []
      begin
        GitHelper.open_git_repository do
          vm_names = prepare_vm_names
          vm_names.each do |vm_name|
            vms.append(find_by_name(vm_name)) if includes_user?(vm_name, user)
          end
        end
      rescue Git::GitExecuteError, RuntimeError => e
        Rails.logger.error(e)
      end
      vms
    end

    def initialize(rbvmomi_vm, folder: nil)
      @vm = rbvmomi_vm
      @folder = folder
    end

    # handles name format YYYYMMDD_vm-name
    def name
      @vsphere_name ||= @vm.name
      if /^\d{8}_vm-/.match? @vsphere_name
        @vsphere_name[12..-1]
      else
        @vsphere_name
      end
    end

    def full_path
      path = [name]
      parent = parent_folder
      until parent.nil?
        path << parent.name
        parent = parent.parent
      end
      path.reverse
    end

    def parent_folder
      @folder ||= root_folder.subfolders(recursive: true).find do |folder|
        folder.vms(recursive: false).include? self
      end
    end

    def parent_folder=(folder)
      @folder = folder
    end

    # Guest OS communication
    def vm_ware_tools?
      tool_status = @vm&.guest&.toolsStatus
      tool_status && %w[toolsOk toolsOld].include?(tool_status)
    end

    def suspend_vm
      @vm.SuspendVM_Task.wait_for_completion if powered_on?
    end

    def reset_vm
      @vm.ResetVM_Task.wait_for_completion if powered_on?
    end

    def shutdown_guest_os
      # Do not `wait_for_completion` here, as `ShutdownGuest` does not offer a useful return value
      # https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html#shutdownGuest
      @vm.ShutdownGuest if powered_on?
    end

    def reboot_guest_os
      # Do not `wait_for_completion` here, as `RebootGuest` does not offer a useful return value
      # https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html#rebootGuest
      @vm.RebootGuest if powered_on?
    end

    # Power state testing
    # We do not provide a power_state? method which just returns a boolean, because vSphere can internally handle
    # more than just two power states and we might later need to respond to more states than just two
    def powered_on?
      summary.runtime.powerState == 'poweredOn'
    end

    def powered_off?
      summary.runtime.powerState == 'poweredOff'
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
    # The archiving process actually pending_revivings_folder.vms.any? { |vm| vm.equal? self }just moves the VM into different folders to communicate their state
    # Therefore we can check those folders to receive the current VM state
    # Archiving then moves a VM into the corresponding folder
    def pending_archivation?
      has_ancestor_folder pending_archivation_folder
    end

    def archived?
      has_ancestor_folder archived_folder
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
      has_ancestor_folder pending_revivings_folder
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
      unless @searched_config
        @config = VirtualMachineConfig.find_by_name name
        @searched_config = true
      end
      @config
    end

    def ensure_config
      @config ||= config || VirtualMachineConfig.create!(name: name)
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

    # Users
    def project
      config&.project
    end

    # Information about the vm
    def boot_time
      summary.runtime.bootTime
    end

    def summary
      @summary ||= @vm.summary
    end

    def macs
      @vm.macs
    end

    def disks
      @vm.disks
    end

    def guest
      @vm.guest
    end

    def guest_heartbeat_status
      @vm.guestHeartbeatStatus
    end

    def host_name
      summary.runtime.host.name
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

    # this method should return all users, including the sudo users
    def users
      users = []
      begin
        GitHelper.open_git_repository do
          remote_users = Puppetscript.read_node_file(name)
          users = remote_users[:users] || []
        end
      rescue Git::GitExecuteError, RuntimeError => e
        Rails.logger.error(e)
      end
      users
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

    def user_name_and_node_script(ids)
      all_users = Puppetscript.read_node_file(name)
      sudo_users = all_users[:admins]
      new_users = User.where(id: ids)
      name_script = Puppetscript.name_script(name)
      node_script = Puppetscript.node_script(name, sudo_users, new_users)
      [name_script, node_script]
    end

    def users=(ids)
      GitHelper.open_git_repository(for_write: true) do |git_writer|
        name_script, node_script = user_name_and_node_script(ids)
        write_node_and_class_file(git_writer, name_script, node_script)
      end
    rescue Git::GitExecuteError, RuntimeError => e
      Rails.logger.error(e)
    end

    def sudo_users=(ids)
      GitHelper.open_git_repository(for_write: true) do |git_writer|
        name_script, node_script = sudo_name_and_node_script(ids)
        write_node_and_class_file(git_writer, name_script, node_script)
      end
    rescue Git::GitExecuteError, RuntimeError => e
      logger.error(e)
    end

    def write_node_and_class_file(git_writer, name_script, node_script)
      git_writer.write_file(Puppetscript.class_file_name(name), name_script)
      git_writer.write_file(Puppetscript.node_file_name(name), node_script)
      message = commit_message(git_writer)
      git_writer.save(message)
    end

    def sudo_users
      admins = []
      begin
        GitHelper.open_git_repository do
          users = Puppetscript.read_node_file(name)
          admins = users[:admins] || []
        end
      rescue Git::GitExecuteError, RuntimeError => e
        Rails.logger.error(e)
      end
      admins
    end

    def sudo_name_and_node_script(ids)
      all_users = Puppetscript.read_node_file(name)
      users = all_users[:users]
      new_sudo_users = User.where(id: ids)
      name_script = Puppetscript.name_script(name)
      node_script = Puppetscript.node_script(name, new_sudo_users, users)
      [name_script, node_script]
    end

    # fine to use for a single vm. If you need to check multiple vms for a user, check with user_vms
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

    def request
      @request ||= Request.accepted.find_by name: name
    end

    #private

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

    def has_ancestor_folder(ancestor_folder)
      folder = parent_folder
      until folder.equal?(ancestor_folder)
        if folder.nil? || folder.equal?(root_folder)
          return false
        end

        folder = folder.parent
      end

      true
    end

    def managed_folder_entry
      @vm
    end
  end
  # rubocop:enable Metrics/ClassLength
end
