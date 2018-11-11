
require 'rails_helper'
require './app/api/vmapi.rb'

RSpec.describe VmApi do
  let(:api) {VmApi.new}

  describe '#connect' do
    let(:setup_methods) do
      [:serviceInstance, :find_datacenter, :hostFolder, :vmFolder, :children, :first, :resourcePool]
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
      api.create_vm(2, 1024, 10000, 'cool vm')
    end
  end

  describe 'all_vms' do
    let(:vm_folder_mock) do
      mock = double
      expect(mock).to receive(:children).and_return([])
      mock
    end
    before :each do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    subject {api.all_vms}

    it 'asks @vm_folder for all vms' do
      api.all_vms
    end

    it 'responds with an array' do
      expect(subject.class).to equal Array
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

    before :each do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    context 'when vm is off' do
      let(:power_state) {'poweredOff'}

      it 'deletes vm' do
        api.delete_vm Faker::FunnyName.name
      end
    end

    context 'when vm is on' do
      let(:power_state) {'poweredOn'}
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

    before :each do
      allow(api).to receive(:connect)
      api.instance_variable_set :@vm_folder, vm_folder_mock
    end

    context 'to on' do
      let(:vm_mock) do
        mock = double
        expect(mock).to receive_message_chain(:PowerOnVM_Task, :wait_for_completion)
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
        mock
      end

      it 'changes PowerState' do
        api.change_power_state(Faker::FunnyName.name, false)
      end
    end

  end
end