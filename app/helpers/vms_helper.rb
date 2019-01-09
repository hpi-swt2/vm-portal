# frozen_string_literal: true

require 'vmapi.rb'

module VmsHelper

  def all_archived_vms
    VmApi.instance.all_vms_in(VmApi.instance.ensure_folder('Archived VMs'))
  end

  def all_pending_archived_vms
    VmApi.instance.all_vms_in(VmApi.instance.ensure_folder('Pending archivings'))
  end

  def is_archived(vm)
    all_archived_vms.include?(vm)
  end

  def all_pending_archivings
    VmApi.instance.all_vms_in(pending_folder)
  end

  def is_pending_archivation(vm)
    all_pending_archivings.include?(vm)
  end

  def set_pending_archivation(vm)
    pending_folder.MoveIntoFolder_Task(list: [vm]).wait_for_completion
  end

  def set_archived(vm)
    archived_folder.MoveIntoFolder_Task(list: [vm]).wait_for_completion
  end

  private

  def pending_folder
    VmApi.instance.ensure_folder('Pending archivings')
  end

  def archived_folder
    VmApi.instance.ensure_folder('Archived VMs')
  end

end
