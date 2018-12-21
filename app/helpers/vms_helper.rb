# frozen_string_literal: true

require 'vmapi.rb'

module VmsHelper

  def all_archived_vms
    VmApi.instance.all_vms_in(VmApi.instance.ensure_folder('Archived VMs'))
  end

end
