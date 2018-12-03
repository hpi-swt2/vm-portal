# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/index.html.erb', type: :view do
  let(:mock_vms) do
    [{
      name: 'My insanely cool vm',
      state: true,
      boot_time: 'Yesterday'
    },
    {
      name: 'Another VM',
      state: false,
      boot_time: 'Friday'
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
    mock_vms.each { |vm|
      expect(rendered).to include vm[:name]
    }
  end

  it 'renders the boot times' do
    expect(rendered).to include mock_vms[0][:boot_time]
    expect(rendered).not_to include mock_vms[1][:boot_time]
  end

  it 'links to vm detail pages' do
    mock_vms.each { |vm|
      expect(rendered).to have_link(vm[:name])
    }
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

end
