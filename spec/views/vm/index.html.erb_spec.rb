# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vm/index.html.erb', type: :view do
  let(:vm) do
    {
        name: 'My insanely cool vm',
        state: true,
        boot_time: 'Yesterday'
    }
  end
  let(:host) do
    {  name: 'someHostMachine',
       model: 'cool machine',
       vendor: 'nice vendor',
       bootTime: 'some long while',
       connectionState: 'connected',
       vm_names: ['a name', 'another name'],
    }
  end

  before do
    assign(:vms, [vm])
    assign(:hosts, [host])
    render
  end

  it 'renders the vms name' do
    expect(rendered).to include vm[:name]
  end

  it 'renders the boot time' do
    expect(rendered).to include vm[:boot_time]
  end

  it 'renders the host machine name' do
    expect(rendered).to include host[:name]
  end

  it 'renders model name' do
    expect(rendered).to include host[:model]
  end

  it 'renders vendor name' do
    expect(rendered).to include host[:vendor]
  end

  it 'renders boot time' do
    expect(rendered).to include host[:bootTime]
  end

  it 'renders connectionState' do
    expect(rendered).to include host[:connectionState]
  end

  it 'renders vm names' do
    host[:vm_names].each do |name|
      expect(rendered).to include name
    end
  end

  it 'links to resource detail pages' do
    expect(rendered).to have_button("Details", count: 2)
  end

  it 'can filter resources' do
    expect(rendered).to have_button("Filter")
  end
end
