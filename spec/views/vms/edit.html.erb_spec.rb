# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/edit.html.erb', type: :view do
  let(:vm) do
    v_sphere_vm_mock 'VM', vm_ware_tools: 'toolsInstalled'
  end
  let(:configuration) do
    config = double
    allow(config).to receive(:description).and_return('hello world')
    allow(config).to receive(:ip).and_return('127.0.0.1')
    allow(config).to receive(:dns).and_return('8.8.8.8')
    config
  end

  let(:current_user) { FactoryBot.create :user }

  before do
    sign_in current_user
    assign(:vm, vm)
    assign(:configuration, configuration)
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
