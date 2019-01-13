# frozen_string_literal: true

# TODO: klären, inwieweit View tests gemacht werden sollen

require 'rails_helper'

RSpec.describe 'vms/show.html.erb', type: :view do
  let(:summary) do
    summary_double = double
    allow(summary_double).to receive_message_chain(:storage, :committed).and_return(100)
    allow(summary_double).to receive_message_chain(:storage, :uncommitted).and_return(100)
    allow(summary_double).to receive_message_chain(:config, :guestId).and_return('Win10')
    allow(summary_double).to receive_message_chain(:config, :guestFullName).and_return('Win10 EE')
    allow(summary_double).to receive_message_chain(:guest, :ipAddress).and_return('0.0.0.0')
    allow(summary_double).to receive_message_chain(:quickStats, :overallCpuUsage).and_return(50)
    allow(summary_double).to receive_message_chain(:config, :cpuReservation).and_return(100)
    allow(summary_double).to receive_message_chain(:quickStats, :guestMemoryUsage).and_return(1024)
    allow(summary_double).to receive_message_chain(:config, :memorySizeMB).and_return(2024)
    allow(summary_double).to receive_message_chain(:config, :numCpu).and_return(2)
    allow(summary_double).to receive_message_chain(:runtime, :powerState).and_return('poweredOn')
    summary_double
  end

  let(:vm_on) do
    { name: 'VM',
      state: true,
      boot_time: Time.current,
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      summary: summary,
      vmwaretools: true }
  end

  let(:vm_on_without_tools) do
    { name: 'VM',
      state: true,
      boot_time: Time.current,
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      summary: summary,
      vmwaretools: false }
  end

  let(:vm_off) do
    { name: 'VM',
      state: false,
      boot_time: Time.current,
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      summary: summary,
      vmwaretools: true }
  end

  before do
    assign(:vm, vm_on)
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm_on[:name]
  end

  it 'shows status when online' do
    expect(rendered).to include 'online'
  end

  it 'shows vm OS' do
    expect(rendered).to include vm_on[:summary].config.guestId
  end

  it 'shows vm OS version' do
    expect(rendered).to include vm_on[:summary].config.guestFullName
  end

  it 'does not shows vm OS when unknown' do
    allow(summary).to receive_message_chain(:config, :guestFullName).and_return('Other (32-bit)')
    expect(rendered).not_to include vm_on[:summary].config.guestFullName
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm_on[:summary].guest.ipAddress
  end

  it 'has a link to delete VM' do
    expect(rendered).to have_link 'Delete'
  end

  it 'shows CPU usage' do
    expect(rendered).to include(
      (vm_on[:summary].quickStats.overallCpuUsage / vm_on[:summary].config.cpuReservation).round.to_s
    )
  end

  it 'shows HDD usage' do
    expect(rendered).to include((vm_on[:summary].storage.committed / 1024**3).to_s)
    expect(rendered).to include((vm_on[:summary].storage.uncommitted / 1024**3).to_s)
    expect(rendered).to include(
      (vm_on[:summary].storage.committed / (vm_on[:summary].storage.committed + vm_on[:summary].storage.uncommitted).round).to_s
    )
  end

  it 'shows RAM usage' do
    expect(rendered).to include((vm_on[:summary].quickStats.guestMemoryUsage.to_f / 1024).round(2).to_s)
    expect(rendered).to include((vm_on[:summary].config.memorySizeMB.to_f / 1024).round(2).to_s)
    expect(rendered).to include((vm_on[:summary].quickStats.guestMemoryUsage.to_f / vm_on[:summary].config.memorySizeMB.to_f).round.to_s)
  end

  it 'shows CPU cores' do
    expect(rendered).to include vm_on[:summary].config.numCpu.to_s
  end

  it 'has power off links when powered on' do
    expect(rendered).to have_link 'Suspend VM'
    expect(rendered).to have_link 'Shutdown Guest OS'
    expect(rendered).to have_link 'Restart Guest OS'
    expect(rendered).to have_link 'Reset'
    expect(rendered).to have_link 'Power Off'
  end

  it 'demands confirmation on critical actions when powered on' do
    expect(rendered).to have_selector("a[href='#{url_for(controller: :vms, action: 'suspend_vm', id: vm_on[:name])}'][data-confirm='Are you sure?']")
    expect(rendered).to have_selector(
      "a[href='#{url_for(controller: :vms, action: 'shutdown_guest_os', id: vm_on[:name])}'][data-confirm='Are you sure?']"
    )
    expect(rendered).to have_selector("a[href='#{url_for(controller: :vms, action: 'reboot_guest_os', id: vm_on[:name])}'][data-confirm='Are you sure?']")
    expect(rendered).to have_selector("a[href='#{url_for(controller: :vms, action: 'reset_vm', id: vm_on[:name])}'][data-confirm='Are you sure?']")
    expect(rendered).to have_selector(
      "a[href='#{url_for(controller: :vms, action: 'change_power_state', id: vm_on[:name])}'][data-confirm='Are you sure?']"
    )
    expect(rendered).to have_selector("a[href='#{url_for(controller: :vms, action: 'destroy', id: vm_on[:name])}'][data-confirm='Are you sure?']")
  end

  it 'has no power on link when powered on' do
    expect(rendered).not_to have_link 'Power On'
  end

  it 'has power on link when powered off' do
    assign(:vm, vm_off)
    render
    expect(rendered).to have_link('Power On')
  end

  it 'has no power off links when powered off' do
    assign(:vm, vm_off)
    rendered = nil
    render
    expect(rendered).not_to have_link 'Suspend VM'
    expect(rendered).not_to have_link 'Shutdown Guest OS'
    expect(rendered).not_to have_link 'Restart Guest OS'
    expect(rendered).not_to have_link 'Reset'
    expect(rendered).not_to have_link 'Power Off'
  end

  it 'shows status when online' do
    assign(:vm, vm_off)
    render
    expect(rendered).to include 'offline'
  end

  it 'displays info when vmwaretools are not installed' do
    assign(:vm, vm_on_without_tools)
    rendered = render
    expect(rendered).not_to have_link 'Shutdown Guest OS'
    expect(rendered).not_to have_link 'Restart Guest OS'
    expect(rendered).to have_link 'Suspend VM'
    expect(rendered).to have_link 'Reset'
    expect(rendered).to have_link 'Power Off'
  end

  it 'demands confirmation on critical actions when vmwaretools are not installed' do
    assign(:vm, vm_on_without_tools)
    rendered = render
    expect(rendered).to have_selector(
      "a[href='#{url_for(controller: :vms, action: 'suspend_vm', id: vm_on_without_tools[:name])}'][data-confirm='Are you sure?']"
    )
    expect(rendered).to have_selector(
      "a[href='#{url_for(controller: :vms, action: 'reset_vm', id: vm_on_without_tools[:name])}'][data-confirm='Are you sure?']"
    )
    expect(rendered).to have_selector(
      "a[href='#{url_for(controller: :vms, action: 'change_power_state', id: vm_on_without_tools[:name])}'][data-confirm='Are you sure?']"
    )
    expect(rendered).to have_selector(
      "a[href='#{url_for(controller: :vms, action: 'destroy', id: vm_on_without_tools[:name])}'][data-confirm='Are you sure?']"
    )
  end

  it 'displays info when vmwaretools are installed' do
    assign(:vm, vm_on)
    rendered = render
    expect(rendered).to have_link 'Suspend VM'
    expect(rendered).to have_link 'Shutdown Guest OS'
    expect(rendered).to have_link 'Restart Guest OS'
    expect(rendered).to have_link 'Reset'
    expect(rendered).to have_link 'Power Off'
  end
end
