# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

RSpec.describe 'vms/edit_config.html.erb', type: :view do
  let(:vm_on) do
    v_sphere_vm_mock 'VM', vm_ware_tools: 'toolsInstalled'
  end

  before do
    assign(:vm, vm_on)
    allow(vm_on).to receive(:macs).and_return(vm_on.macs)
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm_on.name
  end

  it 'shows vm Mac address' do
    expect(rendered).to include vm_on.macs.first
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm_on.ip
  end

  it 'shows vm DNS address' do
    expect(rendered).to include vm_on.dns
  end
end
