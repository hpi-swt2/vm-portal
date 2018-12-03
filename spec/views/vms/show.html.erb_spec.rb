# frozen_string_literal: true

# TODO: klären, inwieweit View tests gemacht werden sollen

require 'rails_helper'

RSpec.describe 'vms/show.html.erb', type: :view do
  let(:summary) do
    summary_double = double
    allow(summary_double).to receive_message_chain(:storage, :committed).and_return(0)
    allow(summary_double).to receive_message_chain(:storage, :uncommitted).and_return(0)
    allow(summary_double).to receive_message_chain(:config, :guestId).and_return('Win10')
    allow(summary_double).to receive_message_chain(:config, :guestFullName).and_return('Win10 EE')
    allow(summary_double).to receive_message_chain(:guest, :ipAddress).and_return('0.0.0.0')
    allow(summary_double).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(0)
    allow(summary_double).to receive_message_chain(:config, :cpuReservation).and_return(0)
    allow(summary_double).to receive_message_chain(:quickStats, :guestMemoryUsage).and_return(0)
    allow(summary_double).to receive_message_chain(:config, :memoryReservation).and_return(0)
    allow(summary_double).to receive_message_chain(:runtime, :powerState).and_return('poweredOn')
    summary_double
  end

  let(:vm_on) do
    { name: 'VM',
      state: true,
      boot_time: 'Thursday',
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      summary: summary }
  end

  let(:vm_off) do
    { name: 'VM',
      state: false,
      boot_time: 'Thursday',
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      summary: summary }
  end

  before do
    assign(:vm, vm_on)
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm_on[:name]
  end

  it 'shows vm boot time' do
    expect(rendered).to include vm_on[:boot_time]
  end

  it 'shows vm OS' do
    expect(rendered).to include vm_on[:summary].config.guestId
  end

  it 'shows vm OS version' do
    expect(rendered).to include vm_on[:summary].config.guestFullName
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm_on[:summary].guest.ipAddress
  end

  it 'has a button to delete VM' do
    expect(rendered).to have_button('Delete')
  end

  it 'has power off buttons' do
    expect(rendered).to have_button('Suspend')
    expect(rendered).to have_button('Shutdown Guest OS')
    expect(rendered).to have_button('Restart Guest OS')
    expect(rendered).to have_button('Reset')
    expect(rendered).to have_button('Power Off')
  end

  it 'has power on button' do 
    assign(:vm, vm_off)
    render
    expect(rendered).to have_button('Power On')
  end
end
