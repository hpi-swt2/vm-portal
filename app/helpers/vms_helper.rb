# frozen_string_literal: true

require 'vmapi.rb'

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

  def notify_changed_users(old_list, new_list, sudo_lists, vm_name)
    removed_users = old_list - new_list
    removed_users.each do |user_id|
      User.find(user_id).notify('Sudo rights revoked', "Your sudo rights on VM '#{vm_name}' have been revoked.") if sudo_lists
      User.find(user_id).notify('User rights revoked', "Your user rights on VM '#{vm_name}' have been revoked.") unless sudo_lists
    end
    added_users = new_list - old_list
    added_users.each do |user_id|
      User.find(user_id).notify('Sudo rights granted', "You have been made sudo user on VM '#{vm_name}'") if sudo_lists
      User.find(user_id).notify('User rights granted', "You have been made user on VM '#{vm_name}'") unless sudo_lists
    end
  end

  def request_for(vm)
    Request.accepted.find { |each| vm.name == each.name }
  end
end
