# frozen_string_literal: true

include 'rbvmomi'
include 'v_sphere_api.rb'

# This class wraps a rbvmomi Virtual Machine and provides easy access to important information
class VirtualMachine

  def initialize(rbvmomi_vm)
    @vm = rbvmomi_vm
  end
  
end
