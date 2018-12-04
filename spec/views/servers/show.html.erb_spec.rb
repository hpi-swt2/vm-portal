# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'servers/show.html.erb', type: :view do
  let(:host) do
    summary = double
    allow(summary).to receive_message_chain(:runtime, :powerState)
    allow(summary).to receive_message_chain(:config, :product, :osType)
    allow(summary).to receive_message_chain(:config, :product, :fullName)
    allow(summary).to receive_message_chain(:hardware, :cpuModel)
    allow(summary).to receive_message_chain(:hardware, :numCpuCores).and_return(0)
    allow(summary).to receive_message_chain(:hardware, :numCpuThreads).and_return(0)
    allow(summary).to receive_message_chain(:hardware, :cpuMhz).and_return(0)
    allow(summary).to receive_message_chain(:hardware, :memorySize).and_return(0)
    allow(summary).to receive_message_chain(:quickStats, :overallMemoryUsage).and_return(0)
    allow(summary).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(0)

    { name: 'aHost',
      vm_names: ['vm'],
      model: 'a cool model',
      vendor: 'the dark side',
      bootTime: 'Thursday',
      connectionState: 'connected',
      summary: summary }
  end

  before do
    assign(:host, host)
    render
  end

  it 'shows host name' do
    expect(rendered).to include host[:name]
  end

  it 'shows vendor' do
    expect(rendered).to include host[:vendor]
  end

  it 'shows model' do
    expect(rendered).to include host[:model]
  end

  it 'shows boot time' do
    expect(rendered).to include host[:bootTime]
  end

  it 'shows vms' do
    host[:vm_names].each do |vm|
      expect(rendered).to include vm
    end
  end

  it 'has reserve button' do
    expect(rendered).to have_button('Reserve')
  end
end
