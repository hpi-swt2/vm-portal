# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'hosts/show.html.erb', type: :view do
  let(:host) do
    summary = double
    datastore = double
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
    allow(summary).to receive_message_chain(:host, :datastore).and_return([datastore])
    allow(datastore).to receive_message_chain(:summary, :capacity).and_return(0)
    allow(datastore).to receive_message_chain(:summary, :freeSpace).and_return(0)

    { name: 'aHost',
      vms: { 'vm' => true },
      model: 'a cool model',
      vendor: 'the dark side',
      bootTime: Time.current,
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

  it 'shows vms' do
    host[:vms].each do |name, state|
      expect(rendered).to include name.to_s
    end
  end

  it 'has reserve link' do
    expect(rendered).to have_link 'Reserve Timeslot'
  end
end
