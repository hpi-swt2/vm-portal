# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

describe VSphere::VirtualMachine do
  it 'does not throw an error when reading users from invalid node file' do
    vm = v_sphere_vm_mock('myVM')
    allow(Puppetscript).to receive(:read_node_file).and_raise('Unsupported Format')
    expect { vm.users }.not_to raise_error(RuntimeError)
  end
end
