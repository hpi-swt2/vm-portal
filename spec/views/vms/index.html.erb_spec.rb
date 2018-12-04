# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/index.html.erb', type: :view do
  let(:vm) do
    {
      name: 'My insanely cool vm',
      state: true,
      boot_time: 'Yesterday'
    }
  end

  let(:param) do
    %w[up_vms down_vms]
  end

  before do
    assign(:vms, [vm])
    assign(:parameters, [param])
    render
  end

  it 'renders the vms name' do
    expect(rendered).to include vm[:name]
  end

  it 'renders the boot time' do
    expect(rendered).to include vm[:boot_time]
  end

  it 'links to resource detail pages' do
    expect(rendered).to have_link(vm[:name], count: 1)
  end

  it 'can filter resources' do
    expect(rendered).to have_button('Filter')
  end
end
