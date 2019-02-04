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
    else
      # type code here
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
    else
      # type code here
    end
  end
end
