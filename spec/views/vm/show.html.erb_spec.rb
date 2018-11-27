# frozen_string_literal: true

# TODO: klÃ¤ren, inwieweit View tests gemacht werden sollen

require 'rails_helper'

RSpec.describe 'vm/show.html.erb', type: :view do
  let(:vm) do
    summary = double
    allow(summary).to receive_message_chain(:storage, :committed).and_return(0)
    allow(summary).to receive_message_chain(:storage, :uncommitted).and_return(0)
    allow(summary).to receive_message_chain(:config, :guestId).and_return('Win10')
    allow(summary).to receive_message_chain(:config, :guestFullName).and_return('Win10 EE')
    allow(summary).to receive_message_chain(:guest, :ipAddress).and_return('0.0.0.0')
    allow(summary).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(0)
    allow(summary).to receive_message_chain(:config, :cpuReservation).and_return(0)
    allow(summary).to receive_message_chain(:quickStats, :guestMemoryUsage).and_return(0)
    allow(summary).to receive_message_chain(:config, :memoryReservation).and_return(0)
    allow(summary).to receive_message_chain(:runtime, :powerState).and_return(0)

    { name: 'VM',
      boot_time: 'Thursday',
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      summary: summary }
  end

  before do
    assign(:vm, vm)
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm[:name]
  end

  it 'shows vm boot time' do
    expect(rendered).to include vm[:boot_time]
  end

  it 'shows vm OS' do
    expect(rendered).to include vm[:summary].config.guestId
  end

  it 'shows vm OS version' do
    expect(rendered).to include vm[:summary].config.guestFullName
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm[:summary].guest.ipAddress
  end
end
