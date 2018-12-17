# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/index.html.erb', type: :view do
  let(:mock_vms) do
    [{
      name: 'My insanely cool vm',
      state: true,
      boot_time: 'Yesterday',
      vmwaretools: true
    }, {
      name: 'Another VM',
      state: false,
      boot_time: 'Friday',
      vmwaretools: true
    }]
  end

  let(:mock_vms_without_tools) do
    [{
      name: 'My insanely cool vm',
      state: true,
      boot_time: 'Yesterday',
      vmwaretools: false
    }, {
      name: 'Another VM',
      state: false,
      boot_time: 'Friday',
      vmwaretools: false
    }]
  end

  let(:param) do
    %w[up_vms down_vms]
  end

  before do
    assign(:vms, mock_vms)
    assign(:parameters, param)
    render
  end

  it 'renders the vm names' do
    mock_vms.each do |vm|
      expect(rendered).to include vm[:name]
    end
  end

  it 'renders the boot times' do
    expect(rendered).to include mock_vms[0][:boot_time]
    expect(rendered).not_to include mock_vms[1][:boot_time]
  end

  it 'links to vm detail pages' do
    mock_vms.each do |vm|
      expect(rendered).to have_link(vm[:name])
    end
  end

  it 'can filter resources' do
    expect(rendered).to have_button('Filter')
  end

  it 'links to new vm page' do
    expect(rendered).to have_button('New')
  end

  it 'links to requests overview page' do
    expect(rendered).to have_button('Requests')
  end

  it 'shows correct power on / off button' do
    expect(rendered).to have_button('Start')
    expect(rendered).to have_button('Shutdown')
  end

  it 'shows no power buttons when vmwaretools are not installed' do
    assign(:vms, mock_vms_without_tools)
    assign(:parameters, param)
    render
    expect(rendered).to have_text('VMWare tools are not installed')
  end

  it 'demands confirmation on shutdown' do
    expect(rendered).to have_selector('input[value="Shutdown"][data-confirm="Are you sure?"]')
  end
end
