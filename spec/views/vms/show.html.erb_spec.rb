# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

RSpec.describe 'vms/show.html.erb', type: :view do
  let(:vm_on) do
    vm = v_sphere_vm_mock 'vm', vm_ware_tools: 'toolsOk'
    vm.ensure_config.description = 'My Description'
    vm
  end

  let(:vm_on_without_tools) do
    v_sphere_vm_mock 'vm'
  end

  let(:vm_off) do
    v_sphere_vm_mock 'vm', power_state: 'powerOff'
  end

  let(:current_user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }

  before do
    sign_in current_user
    assign(:vm, vm_on)
    connection = v_sphere_connection_mock normal_vms: [vm_on, vm_on_without_tools, vm_off]
    allow(VSphere::Connection).to receive(:instance).and_return connection
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm_on.name
  end

  it 'shows status when online' do
    expect(rendered).to include vm_on.status.to_s
  end

  it 'shows vm OS' do
    expect(rendered).to include vm_on.summary.config.guestId
  end

  it 'shows vm OS version' do
    expect(rendered).to include vm_on.summary.config.guestFullName
  end

  context 'when the OS is unknown' do
    it 'does not shows vms OS' do
      allow(vm_on).to receive_message_chain(:summary, :config, :guestFullName).and_return('Other (32-bit)')
      expect(rendered).not_to include vm_on.summary.config.guestFullName
    end
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm_on.ip
  end

  it 'shows CPU usage' do
    expect(rendered).to include((vm_on.summary.quickStats.overallCpuDemand / vm_on.summary.runtime.maxCpuUsage).round.to_s)
  end

  it 'shows the description' do
    expect(rendered).to include(vm_on.config.description)
  end

  it 'shows HDD usage' do
    expect(rendered).to include((vm_on.summary.storage.committed / 1024**3).to_s)
    expect(rendered).to include((vm_on.summary.storage.uncommitted / 1024**3).to_s)
    expect(rendered).to include((vm_on.summary.storage.committed / (vm_on.summary.storage.committed + vm_on.summary.storage.uncommitted).round).to_s)
  end

  it 'shows RAM usage' do
    expect(rendered).to include((vm_on.summary.quickStats.guestMemoryUsage.to_f / 1024).round(2).to_s)
    expect(rendered).to include((vm_on.summary.config.memorySizeMB.to_f / 1024).round(2).to_s)
    expect(rendered).to include((vm_on.summary.quickStats.guestMemoryUsage.to_f / vm_on.summary.config.memorySizeMB.to_f).round.to_s)
  end

  it 'shows CPU cores' do
    expect(rendered).to include vm_on.summary.config.numCpu.to_s
  end

  context 'when vm is offline' do
    before do
      assign(:vm, vm_off)
      render
    end

    it 'shows status' do
      expect(rendered).to include vm_on.status.to_s
    end
  end

  context 'when the current user is not a root user' do
    it 'does not have any links to manage power state' do
      expect(rendered).not_to have_link href: change_power_state_vm_path(vm_off.name)
    end

    it 'does not have links to Puppet Scripts on GitHub' do
      expect(rendered).to_not have_css 'a[href*="github.com"]'
    end
  end

  context 'when the current user is an admin' do
    let(:current_user) { admin }

    context 'when powered on' do
      it 'has power off links' do
        expect(rendered).to have_link href: suspend_vm_vm_path(vm_on.name)
        expect(rendered).to have_link href: shutdown_guest_os_vm_path(vm_on.name)
        expect(rendered).to have_link href: reboot_guest_os_vm_path(vm_on.name)
        expect(rendered).to have_link href: reset_vm_vm_path(vm_on.name)
        expect(rendered).to have_link 'Power Off', href: change_power_state_vm_path(vm_on.name)
      end

      it 'has links to Puppet Scripts on GitHub' do
        expect(rendered).to have_css 'a[href*="github.com"]', minimum: 1
      end
    end

    context 'when powered off' do
      before do
        assign(:vm, vm_off)
        render
      end

      it 'has power on link' do
        expect(rendered).to have_link 'Power On', href: change_power_state_vm_path(vm_off.name)
      end
    end
  end

  context 'when the current user is a root user' do
    before do
      associate_users_with_vms(admins: [current_user], vms: [vm_on])
      render
    end

    it 'has a link to edit information' do
      expect(rendered).to have_link href: edit_vm_path(vm_on.name)
    end

    context 'when powered on' do
      it 'has power off links' do
        expect(rendered).to have_link href: suspend_vm_vm_path(vm_on.name)
        expect(rendered).to have_link href: shutdown_guest_os_vm_path(vm_on.name)
        expect(rendered).to have_link href: reboot_guest_os_vm_path(vm_on.name)
        expect(rendered).to have_link href: reset_vm_vm_path(vm_on.name)
        expect(rendered).to have_link 'Power Off', href: change_power_state_vm_path(vm_on.name)
      end

      it 'demands confirmation on critical actions' do
        expect(rendered).to have_selector("a[href='#{suspend_vm_vm_path(vm_on.name)}'][data-confirm]")
        expect(rendered).to have_selector("a[href='#{shutdown_guest_os_vm_path(vm_on.name)}'][data-confirm]")
        expect(rendered).to have_selector("a[href='#{reboot_guest_os_vm_path(vm_on.name)}'][data-confirm]")
        expect(rendered).to have_selector("a[href='#{reset_vm_vm_path(vm_on.name)}'][data-confirm]")
        expect(rendered).to have_selector("a[href='#{change_power_state_vm_path(vm_on.name)}'][data-confirm]")
      end

      it 'has no power on link' do
        expect(rendered).to_not have_link 'Power On', href: change_power_state_vm_path(vm_on.name)
      end
    end

    context 'when powered off' do
      before do
        assign(:vm, vm_off)
        render
      end

      it 'has power on link' do
        expect(rendered).to have_link 'Power On', href: change_power_state_vm_path(vm_off.name)
      end

      it 'has no power off links' do
        rendered = render
        expect(rendered).to_not have_link href: suspend_vm_vm_path(vm_off.name)
        expect(rendered).to_not have_link href: shutdown_guest_os_vm_path(vm_off.name)
        expect(rendered).to_not have_link href: reboot_guest_os_vm_path(vm_off.name)
        expect(rendered).to_not have_link href: reset_vm_vm_path(vm_off.name)
        expect(rendered).to_not have_link 'Power Off', href: change_power_state_vm_path(vm_off.name)
      end
    end

    context 'when vm_ware_tools are not installed' do
      before do
        assign(:vm, vm_on_without_tools)
        render
      end

      it 'displays info that they are not installed' do
        rendered = render
        expect(rendered).to_not have_link href: shutdown_guest_os_vm_path(vm_on_without_tools.name)
        expect(rendered).to_not have_link href: reboot_guest_os_vm_path(vm_on_without_tools.name)
        expect(rendered).to have_link href: suspend_vm_vm_path(vm_on_without_tools.name)
        expect(rendered).to have_link href: reset_vm_vm_path(vm_on_without_tools.name)
        expect(rendered).to have_link 'Power Off', href: change_power_state_vm_path(vm_on_without_tools.name)
      end

      it 'demands confirmation on critical actions' do
        expect(rendered).to have_selector("a[href='#{suspend_vm_vm_path(vm_on_without_tools.name)}'][data-confirm]")
        expect(rendered).to have_selector("a[href='#{reset_vm_vm_path(vm_on_without_tools.name)}'][data-confirm]")
        expect(rendered).to have_selector("a[href='#{change_power_state_vm_path(vm_on_without_tools.name)}'][data-confirm]")
      end
    end
  end
end
