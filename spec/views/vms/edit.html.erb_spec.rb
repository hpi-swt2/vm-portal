# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/edit.html.erb', type: :view do
  let(:vm) do
    v_sphere_vm_mock 'VM', vm_ware_tools: 'toolsInstalled'
  end

  before do
    assign(:vm, vm)
    render
  end

  it 'shows vm name' do
    expect(rendered).to have_text vm.name
  end

  it 'says edit' do
    expect(rendered).to have_text 'Edit'
  end

  it 'has a button to save' do
    expect(rendered).to have_button 'Update VM information'
  end
end
