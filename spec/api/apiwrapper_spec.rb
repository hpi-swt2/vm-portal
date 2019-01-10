# frozen_string_literal: true

require 'rails_helper'
require './app/api/vmapi.rb'

RSpec.describe VmApi do
  let(:api) { described_class.instance }

  describe '#connect' do
    let(:setup_methods) do
      %i[serviceInstance find_datacenter hostFolder vmFolder children first resourcePool all_hosts find_vm vm]
    end

    let(:double_api) do
      doub_api = double
      setup_methods.each do |method|
        allow(doub_api).to receive(method).and_return(doub_api)
      end
      doub_api
    end

    it 'connects to server and retrieves basic information' do
      expect(RbVmomi::VIM).to receive(:connect).and_return(double_api)
      api.send(:connect)
    end
  end

  describe '#create_vm' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive_message_chain(:CreateVM_Task, :wait_for_completion)
      mock
    end

    it 'asks API to create a vm' do
      expect(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
      api.create_vm(2, 1024, 10_000, 'cool vm')
    end
  end

  describe 'all_vms' do
    subject { api.all_vms }

    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:children).and_return([])
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    it 'asks @vm_folder for all vms' do
      api.all_vms
    end

    it 'responds with an array' do
      expect(subject.class).to equal Array
    end
  end

  describe 'all_hosts' do
    subject { api.all_hosts }

    let(:clusters_mock) do
      [cluster_mock]
    end

    let(:cluster_mock) do
      mock = double
      expect(mock).to receive(:host).and_return([host_mock])
      mock
    end

    let(:host_mock) do
      mock = double
      expect(mock).to receive(:vm).and_return([vm_mock])
      expect(mock).to receive(:name).and_return('a name')
      allow(mock).to receive_message_chain(:hardware, :systemInfo, :vendor).and_return('name')
      allow(mock).to receive_message_chain(:hardware, :systemInfo, :model).and_return('brot')
      allow(mock).to receive_message_chain(:runtime, :bootTime).and_return('101010')
      allow(mock).to receive_message_chain(:runtime, :connectionState).and_return('no idea lol')
      allow(mock).to receive(:summary).and_return(nil)
      mock
    end

    let(:vm_mock) do
      mock = double
      expect(mock).to receive(:name).and_return(vm)
      allow(mock).to receive_message_chain(:runtime, :powerState).and_return('poweredOn')
      mock
    end

    let(:vm) do
      { 'name' => true,
        'another name' => false }
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@clusters, clusters_mock
    end

    it 'asks @hosts for all hosts' do
      api.all_hosts
    end

    it 'responds with an array' do
      expect(subject.class).to equal Array
    end
  end

  describe '#get_vm' do
    vm_name = 'VM'
    subject { api.get_vm_info(vm_name) }

    let(:vm_mock) do
      mock = double
      summary = double
      guest = double
      expect(mock).to receive(:name).and_return(vm_name)
      allow(mock).to receive(:summary).and_return(summary)
      allow(summary).to receive_message_chain(:runtime, :host, :name).and_return('aHost')
      allow(mock).to receive_message_chain(:summary, :runtime, :host, :name).and_return('aHost')
      allow(mock).to receive_message_chain(:runtime, :bootTime).and_return('Thursday')
      allow(mock).to receive_message_chain(:runtime, :powerState).and_return('poweredOn')
      allow(mock).to receive(:guestHeartbeatStatus).and_return('running')
      allow(mock).to receive(:guest).and_return(guest)
      allow(guest).to receive(:toolsStatus).and_return('toolsOk')
      mock
    end

    before do
      allow(api).to receive(:connect)
      allow(api).to receive(:find_vm).and_return(vm_mock)
    end

    it 'finds the correct vm' do
      expect(subject[:name]).to equal vm_name
    end
  end

  describe '#get_host' do
    host_name = 'host'
    subject { api.get_host(host_name) }

    let(:hosts_mock) do
      [{ name: host_name }]
    end

    before do
      allow(api).to receive(:connect)
      expect(api).to receive(:all_hosts)
      api.instance_variable_set :@hosts, hosts_mock
    end

    it 'asks @hosts to find host' do
      api.get_host host_name
    end

    it 'responds with correct host' do
      expect(subject[:name]).to equal host_name
    end
  end

  describe '#delete_vm' do
    let(:vm_mock) do
      mock = double
      expect(mock).to receive_message_chain(:Destroy_Task, :wait_for_completion)
      expect(mock).to receive_message_chain(:runtime, :powerState).and_return(power_state)
      mock
    end

    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:traverse).and_return(vm_mock)
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    context 'when vm is off' do
      let(:power_state) { 'poweredOff' }

      it 'deletes vm' do
        api.delete_vm Faker::FunnyName.name
      end
    end

    context 'when vm is on' do
      let(:power_state) { 'poweredOn' }
      let(:vm_mock) do
        expect(super()).to receive_message_chain(:PowerOffVM_Task, :wait_for_completion)
        super()
      end

      it 'turns vm off and deletes vm' do
        api.delete_vm Faker::FunnyName.name
      end
    end
  end

  describe '#change_power_state' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:traverse).and_return(vm_mock)
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    context 'to on' do
      let(:vm_mock) do
        mock = double
        expect(mock).to receive_message_chain(:PowerOnVM_Task, :wait_for_completion)
        allow(mock).to receive_message_chain(:runtime, :powerState).and_return('poweredOff')
        mock
      end

      it 'changes PowerState' do
        api.change_power_state(Faker::FunnyName.name, true)
      end
    end

    context 'to off' do
      let(:vm_mock) do
        mock = double
        expect(mock).to receive_message_chain(:PowerOffVM_Task, :wait_for_completion)
        allow(mock).to receive_message_chain(:runtime, :powerState).and_return('poweredOn')
        mock
      end

      it 'changes PowerState' do
        api.change_power_state(Faker::FunnyName.name, false)
      end
    end
  end

  describe '#suspend_vm' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:traverse).and_return(vm_mock)
      mock
    end

    let(:vm_mock) do
      mock = double
      expect(mock).to receive_message_chain(:SuspendVM_Task, :wait_for_completion)
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    it 'suspends VM' do
      api.suspend_vm(Faker::FunnyName)
    end
  end

  describe '#reset_vm' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:traverse).and_return(vm_mock)
      mock
    end

    let(:vm_mock) do
      mock = double
      expect(mock).to receive_message_chain(:ResetVM_Task, :wait_for_completion)
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    it 'resest the VM' do
      api.reset_vm(Faker::FunnyName)
    end
  end

  describe '#shutdown_guest_os' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:traverse).and_return(vm_mock)
      mock
    end

    let(:vm_mock) do
      mock = double
      expect(mock).to receive_message_chain(:ShutdownGuest, :wait_for_completion)
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    it 'shuts down the guest OS' do
      api.shutdown_guest_os(Faker::FunnyName)
    end
  end

  describe '#reboot_guest_os' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:traverse).and_return(vm_mock)
      mock
    end

    let(:vm_mock) do
      mock = double
      expect(mock).to receive_message_chain(:RebootGuest, :wait_for_completion)
      mock
    end

    before do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    it 'reboots the guest OS' do
      api.reboot_guest_os(Faker::FunnyName)
    end
  end

  describe '#vm_users' do

    let(:vm_name) { 'My fancy VM' }

    let(:vm_mock) do
      mock = double
      allow(mock).to receive(:name).and_return(vm_name)
      mock
    end

    it 'returns empty list if no matching request exists' do
      expect(VmApi.instance.vm_users(vm_mock)).to be_empty()
    end

    let(:user) { FactoryBot.create(:user) }

    it 'returns the users associated to the request' do
      FactoryBot.create :accepted_request, name: vm_name, users: [user]

      expect(VmApi.instance.vm_users(vm_mock)).to include(user)
    end

    it 'returns an empty list no the matching request is not accepted' do
      FactoryBot.create :rejected_request, name: vm_name, users: [user]

      expect(VmApi.instance.vm_users(vm_mock)).to be_empty
    end

  end
end
