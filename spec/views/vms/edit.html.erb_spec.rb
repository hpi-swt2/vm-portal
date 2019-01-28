# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/edit.html.erb', type: :view do
  let(:request) { FactoryBot.build :accepted_request }

  let(:vm) do
    v_sphere_vm_mock 'VM', vm_ware_tools: 'toolsInstalled'
  end

  before do
    assign(:vm, vm)
    assign(:request, request)
    render
  end

  it 'shows vm name' do
    expect(rendered).to have_text vm.name
  end

  it 'says edit' do
    expect(rendered).to have_text 'Edit'
  end
end
