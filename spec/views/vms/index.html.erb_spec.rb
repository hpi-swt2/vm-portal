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

  let(:current_user) { FactoryBot.create :user }

  before do
    assign(:vms, mock_vms)
    assign(:parameters, param)
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:archived_vms, [])
    assign(:pending_archivation_vms, [])
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

    it 'links to new vm page' do
      expect(rendered).to have_button('New')
    end

    it 'links to requests overview page' do
      expect(rendered).to have_button('Requests')
    end
  end

  context 'when the user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'does not link to new vm page' do
      expect(rendered).not_to have_button('New')
    end

    it 'does not link to requests overview page' do
      expect(rendered).not_to have_button('Requests')
    end
  end
end
