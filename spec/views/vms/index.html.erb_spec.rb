# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

RSpec.describe 'vms/index.html.erb', type: :view do
  let(:mock_vms) do
    [v_sphere_vm_mock('My insanely cool vm',
                      power_state: 'poweredOn',
                      vm_ware_tools: 'toolsInstalled'),
     v_sphere_vm_mock('Another VM',
                      power_state: 'poweredOff',
                      boot_time: 'Friday',
                      vm_ware_tools: 'toolsInstalled')]
  end

  let(:mock_vms_without_tools) do
    [v_sphere_vm_mock('My insanely cool vm',
                      vm_ware_tools: 'toolsNotInstalled'),
     v_sphere_vm_mock('Another VM',
                      power_state: 'poweredOff',
                      boot_time: 'Friday',
                      vm_ware_tools: 'toolsNotInstalled')]
  end

  let(:param) do
    %w[up_vms down_vms]
  end

  let(:current_user) { FactoryBot.create :user }

  before do
    assign(:vms, mock_vms)
    assign(:parameters, param)
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:archived_vms, [])
    assign(:pending_archivation_vms, [])
    assign(:pending_reviving_vms, [])
    render
  end

  it 'renders the vm names' do
    mock_vms.each do |vm|
      expect(rendered).to include vm.name
    end
  end

  it 'renders the boot times' do
    expect(rendered).to include mock_vms.first.boot_time.to_s
    expect(rendered).not_to include mock_vms.second.boot_time
  end

  it 'links to vm detail pages' do
    mock_vms.each do |vm|
      expect(rendered).to have_link(vm.name)
    end
  end

  it 'can filter resources' do
    expect(rendered).to have_button('Filter')
  end

  it 'shows correct power on / off button' do
    expect(rendered).to have_button('Start')
    expect(rendered).to have_button('Shutdown')
  end

  it 'demands confirmation on shutdown' do
    expect(rendered).to have_selector('input[value="Shutdown"][data-confirm="Are you sure?"]')
  end

  it 'shows no power buttons when vmwaretools are not installed' do
    assign(:vms, mock_vms_without_tools)
    assign(:parameters, param)
    render
    expect(rendered).to have_text('VMWare tools are not installed')
  end

  context 'when the user is a user' do
    let(:current_user) { FactoryBot.create :user }

    it 'does not link to new vm page' do
      expect(rendered).not_to have_button('New')
    end

    it 'does not link to requests overview page' do
      expect(rendered).not_to have_button('Requests')
    end
  end

  context 'when the user is an employee' do
    let(:current_user) { FactoryBot.create :employee }

    it 'links to requests overview page' do
      expect(rendered).to have_button('Requests')
    end
  end

  context 'when the user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'links to requests overview page' do
      expect(rendered).to have_button('Requests')
    end
  end
end
