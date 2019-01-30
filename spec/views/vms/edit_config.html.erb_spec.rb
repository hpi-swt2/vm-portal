# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

RSpec.describe 'vms/edit_config.html.erb', type: :view do
  let(:vm_on) do
    v_sphere_vm_mock 'vm', vm_ware_tools: 'toolsInstalled'
  end

  let(:request) { FactoryBot.create :accepted_request, name: 'vm' }

  before do
    assign(:request, request)
    assign(:vm, vm_on)
    vm_on.ensure_config
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm_on.name
  end

  it 'shows vm Mac address' do
    expect(rendered).to include vm_on.macs.first.second
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm_on.ip
  end

  it 'shows vm DNS address' do
    expect(rendered).to include vm_on.dns
  end

  it 'shows vm operating system' do
    expect(rendered).to include request.operating_system
  end
end
