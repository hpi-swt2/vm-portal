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
       cores: 99,
       threads: 99,
       stats: {  usedCPU: 33,
                 totalCPU: 44,
                 usedMem: 5777,
                 totalMem: 6336 } }
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

  it 'calculates host cpu usage' do
    expect(rendered).to include((Float(host[:stats][:usedCPU]) / Float(host[:stats][:totalCPU]) * 100.00).round(2).to_s)
  end

  it 'renders used RAM' do
    expect(rendered).to include((host[:stats][:usedMem] / 1000).round(2).to_s)
  end

  it 'renders available RAM' do
    expect(rendered).to include((host[:stats][:totalMem] / 1000).round(2).to_s)
  end

  it 'renders host cpu cores' do
    expect(rendered).to include host[:cores].to_s
  end

  it 'renders host cpu threads' do
    expect(rendered).to include host[:threads].to_s
  end

  it 'links to resource detail pages' do
    @vms.each do |vm|
      expect(rendered).to have_link("details", href: "./#{vm[:name]}")
    end
    @hosts.each do |host|
      expect(rendered).to have_link("details", href: "../host/#{host[:name]}")
    end
  end
end
