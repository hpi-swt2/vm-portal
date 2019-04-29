# frozen_string_literal: true

module VmsHelper
  def button_style_for(vm)
    case vm.status
    when :archived
      'bg-danger'
    when :pending_archivation
      'bg-warning'
    when :pending_reviving
      'bg-info'
    when :online
      'bg-success'
    when :offline
      'bg-danger'
    end
  end

  def status_for(vm)
    case vm.status
    when :archived
      'archived'
    when :pending_archivation
      'to be archived'
    when :pending_reviving
      'to be revived'
    when :online
      'online'
    when :offline
      'offline'
    end
  end

  def status_color(vm)
    status = vm.status
    if status == :archived
      'bg-secondary'
    else
      status == :online ? 'bg-success' : 'bg-danger'
    end
  end

  def notify_changed_users(old_list, new_list, sudo_lists, vm_name)
    removed_users = old_list - new_list
    removed_users.each do |user|
      user.notify('Sudo rights revoked', "Your sudo rights on VM '#{vm_name}' have been revoked.") if sudo_lists
      user.notify('User rights revoked', "Your user rights on VM '#{vm_name}' have been revoked.") unless sudo_lists
    end
    added_users = new_list - old_list
    added_users.each do |user|
      user.notify('Sudo rights granted', "You have been made sudo user on VM '#{vm_name}'") if sudo_lists
      user.notify('User rights granted', "You have been made user on VM '#{vm_name}'") unless sudo_lists
    end
  end

  def should_be_shown(vms_array)
    !vms_array.nil? && !vms_array.empty?
  end
end
