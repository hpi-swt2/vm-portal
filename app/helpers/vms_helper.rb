# frozen_string_literal: true

require 'vmapi.rb'

module VmsHelper
  # TODO: delete archivation requests
  def allowed_to_be_archived?(vm)
    request = ArchivationRequest.find_by_name vm.name
    if request
      request.can_be_executed?
    else
      true
    end
  end

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
end
