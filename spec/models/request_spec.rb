# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do
  describe 'validation tests' do
    let(:request) { FactoryBot.build :request }

    context 'when request is invalid' do
      it 'is invalid with no name' do
        request.name = ''
        expect(request).to be_invalid
      end

      it 'is invalid with too long name' do
        request.name = 'ThisNameIsWayTooLoooong'
        expect(request).to be_invalid
      end

      it 'is invalid when it contains special signs besides -' do
        request.name = 'IsThisValid?!'
        expect(request).to be_invalid
      end

      it 'is invalid with no cpu_cores specifiation' do
        request.cpu_cores = nil
        expect(request).to be_invalid
      end

      it 'is invalid with no ram specifiation' do
        request.ram_mb = nil
        expect(request).to be_invalid
      end

      it 'is invalid with no storage specifiation' do
        request.storage_mb = nil
        expect(request).to be_invalid
      end

      it 'is invalid with no operating_system specification' do
        request.operating_system = ''
        expect(request).to be_invalid
      end

      it 'is invalid with negative cpu_cores specifiation' do
        request.cpu_cores = -1
        expect(request).to be_invalid
      end

      it 'is invalid with to many cpu_cores ' do
        request.cpu_cores = Request::MAX_CPU_CORES + 1
        expect(request).to be_invalid
      end

      it 'is invalid with negative ram specifiation' do
        request.ram_mb = -1
        expect(request).to be_invalid
      end

      it 'is invalid with to much ram' do
        request.ram_mb = Request::MAX_RAM_MB + 1
        expect(request).to be_invalid
      end

      it 'is invalid with negative storage specifiation' do
        request.storage_mb = -1
        expect(request).to be_invalid
      end

      it 'is invalid with to much storage' do
        request.storage_mb = Request::MAX_STORAGE_MB + 1
        expect(request).to be_invalid
      end

      it 'is invalid with no description' do
        request.description = nil
        expect(request).to be_invalid
      end

      it 'is invalid if the name already exists' do
        FactoryBot.create(:request, name: 'DoubledName')
        request = FactoryBot.build(:request, name: 'DoubledName')
        expect(request).to be_invalid
      end
    end

    context 'when request is valid' do
      it 'is valid with valid attributes' do
        request = FactoryBot.build(:request, name: 'TestVM')
        expect(request).to be_valid
      end
    end
  end

  describe 'method tests' do
    before do
      @request = FactoryBot.create :request
      @user = FactoryBot.build :user
    end

    context 'when accepting a request' do
      it 'changes status to accepted' do
        @request.accept!
        expect(@request.status).to eq('accepted')
      end
    end

    context 'given a request and an user' do
      it 'creates sudo user assignments correctly' do
        @request.assign_sudo_users([@user.id])
        expect((@request.sudo_user_assignments.select { |assignment| assignment.user_id == @user.id }).size).to eq(1)
      end
    end

    context 'when having a non sudo user' do
      before do
        @assignment = @request.users_assigned_to_requests.build(user_id: @user.id, sudo: false)
      end

      it 'does not return a sudo user' do
        expect(@request.sudo_user_assignments.include?(@assignment)).to be false
      end

      it 'does return a non sudo user' do
        expect(@request.non_sudo_user_assignments.include?(@assignment)).to be true
      end
    end

    context 'when having a sudo user' do
      before do
        @sudo_assignment = @request.users_assigned_to_requests.build(user_id: @user.id, sudo: true)
      end

      it 'does return a sudo user' do
        expect(@request.sudo_user_assignments.include?(@sudo_assignment)).to be true
      end

      it 'does not return a non sudo user' do
        expect(@request.non_sudo_user_assignments.include?(@sudo_assignment)).to be false
      end
    end

    context 'when having a user being assigned as user and sudo user' do
      before do
        @request = FactoryBot.create(:request, name: 'MyVM1', user_ids: [@user.id])
        @request.assign_sudo_users([@user.id])
      end

      it 'creates a sudo user assignment' do
        expect((@request.sudo_user_assignments.select { |assignment| assignment.user_id == @user.id && assignment.sudo == true }).size).to eq(1)
      end

      it 'does not create a user assignment' do
        expect(@request.users_assigned_to_requests.select { |assignment| assignment.user_id == @user.id && assignment.sudo == false }).to be_empty
      end
    end
  end

  describe 'puppet script helper methods' do
    before do
      @request = FactoryBot.create(:request_with_users)
    end

    it 'returns correct declaration script for a given request' do
      script = @request.generate_puppet_name_script
      expected_string = <<~NAME_SCRIPT
        node \'vm-MyVM\'{

            if defined( node_vm-MyVM) {
                        class { node_vm-MyVM: }
            }
        }
      NAME_SCRIPT
      expect(script).to eq(expected_string)
    end

    it 'returns correct initialization script for a given request' do
      script = @request.generate_puppet_node_script
      expected_string = <<~NODE_SCRIPT
        class node_vm-MyVM {
                $admins = []
                $users = ["Max.Mustermann", "Max.Mustermann", "Max.Mustermann", "Max.Mustermann"]

                realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
                realize(Accounts::Virtual[$users])
        }
      NODE_SCRIPT
      expect(script).to eq(expected_string)
    end
  end

  describe 'push to git' do
    let(:request) { FactoryBot.build :request }

    before do
      @git = double
      @status = double
      allow(@git).to receive(:config).with('user.name', 'test_user_name')
      allow(@git).to receive(:config).with('user.email', 'test_user_email')
      allow(@git).to receive(:status) { @status }
      allow(@git).to receive(:add)
      allow(@git).to receive(:commit_all)
      allow(@git).to receive(:push)

      @path = File.join Rails.root, 'public', 'puppet_script_temp', ENV['GIT_REPOSITORY_NAME']
      node_path = File.join @path, 'Node'
      name_path = File.join @path, 'Name'

      git_class = class_double('Git')
                  .as_stubbed_const(transfer_nested_constants: true)

      allow(git_class).to receive(:clone) do
        FileUtils.mkdir_p(@path) unless File.exist?(@path)
        FileUtils.mkdir_p(node_path) unless File.exist?(node_path)
        FileUtils.mkdir_p(name_path) unless File.exist?(name_path)
        @git
      end
    end

    after do
      FileUtils.rm_rf(@path) if File.exist?(@path)
    end

    context 'with a new puppet script' do
      before do
        allow(@status).to receive(:changed).and_return([])
        allow(@status).to receive(:added).and_return(['added_file'])
      end

      it 'correctly calls git' do
        expect(@git).to receive(:config).with('user.name', 'test_user_name')
        expect(@git).to receive(:config).with('user.email', 'test_user_email')
        expect(@git).to(receive(:status).once) { @status }
        expect(@status).to receive(:added).once
        expect(@status).not_to receive(:changed)

        expect(@git).to receive(:add)
        expect(@git).to receive(:commit_all)
        expect(@git).to receive(:push)
        request.push_to_git
      end

      it 'returns a success message' do
        expect(request.push_to_git).to eq(notice: 'Added file and pushed to git.')
      end
    end

    context 'with a changed puppet script' do
      before do
        allow(@status).to receive(:changed).and_return(['changed_file'])
        allow(@status).to receive(:added).and_return([])
      end

      it 'correctly calls git' do
        expect(@git).to receive(:config).with('user.name', 'test_user_name')
        expect(@git).to receive(:config).with('user.email', 'test_user_email')
        expect(@git).to(receive(:status).twice) { @status }
        expect(@status).to receive(:added).once
        expect(@status).to receive(:changed).once

        expect(@git).to receive(:add)
        expect(@git).to receive(:commit_all)
        expect(@git).to receive(:push)
        request.push_to_git
      end

      it 'returns a success message' do
        expect(request.push_to_git).to eq(notice: 'Changed file and pushed to git.')
      end
    end

    context 'without any changes' do
      before do
        allow(@status).to receive(:changed).and_return([])
        allow(@status).to receive(:added).and_return([])
      end

      it 'correctly calls git' do
        expect(@git).to receive(:config).with('user.name', 'test_user_name')
        expect(@git).to receive(:config).with('user.email', 'test_user_email')
        expect(@git).to(receive(:status).twice) { @status }
        expect(@status).to receive(:added).once
        expect(@status).to receive(:changed).once

        expect(@git).to receive(:add)
        expect(@git).not_to receive(:commit_all)
        expect(@git).not_to receive(:push)
        request.push_to_git
      end

      it 'returns a success message' do
        expect(request.push_to_git).to eq(notice: 'Already up to date.')
      end
    end
  end
end
