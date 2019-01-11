# frozen_string_literal: true

require 'rbvmomi'
require 'v_sphere_api'

# This class wraps a rbvmomi Virtual Machine and provides easy access to important information
module VSphere
  class VirtualMachine

    def initialize(rbvmomi_vm)
      @v_sphere = VSphereApi.instance
      @vm = rbvmomi_vm
    end

    def name
      @vm.name
    end

    def boot_time
      @vm.runtime.bootTime
    end

    def vm_ware_tools?
      @vm.guest.toolsStatus != 'toolsNotInstalled'
    end

    def powered_on?
      @vm.runtime.powerState == 'poweredOn'
    end

    def pending_archivation?
      pending_archivation_folder.vms.any? { |vm| vm.equal? self }
    end

    def archived?
      archived_folder.vms.any? { |vm| vm.equal? self }
    end

    def equal?(other)
      other.name == name
    end

    private

    def archived_folder
      @v_sphere.root_folder.ensure_folder('Archived VMs')
    end

    def pending_archivation_folder
      @v_sphere.root_folder.ensure_folder('Pending archivings')
    end
  end
end
