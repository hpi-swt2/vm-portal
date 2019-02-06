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
        request.name = 'isthisvalid?!'
        expect(request).to be_invalid
      end

      it 'is invalid when it contains upper case letters' do
        request.name = 'IsThisValid'
        expect(request).to be_invalid
      end

      it 'is invalid when it contains whitespaces' do
        request.name = 'is this valid'
        expect(request).to be_invalid
      end

      it 'is invalid with no cpu_cores specifiation' do
        request.cpu_cores = nil
        expect(request).to be_invalid
      end

      it 'is invalid with no ram specifiation' do
        request.ram_gb = nil
        expect(request).to be_invalid
      end

      it 'is invalid with no storage specifiation' do
        request.storage_gb = nil
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

      it 'is invalid with too many cpu_cores ' do
        request.cpu_cores = Request::MAX_CPU_CORES + 1
        expect(request).to be_invalid
      end

      it 'is invalid with negative ram specifiation' do
        request.ram_gb = -1
        expect(request).to be_invalid
      end

      it 'is invalid with too much ram' do
        request.ram_gb = Request::MAX_RAM_GB + 1
        expect(request).to be_invalid
      end

      it 'is invalid with negative storage specifiation' do
        request.storage_gb = -1
        expect(request).to be_invalid
      end

      it 'is invalid with too much storage' do
        request.storage_gb = Request::MAX_STORAGE_GB + 1
        expect(request).to be_invalid
      end

      it 'is invalid with no description' do
        request.description = nil
        expect(request).to be_invalid
      end

      it 'is invalid if the name already exists' do
        FactoryBot.create(:request, name: 'doubledname')
        request = FactoryBot.build(:request, name: 'doubledname')
        expect(request).to be_invalid
      end
    end

    context 'when request is valid' do
      it 'is valid with valid attributes' do
        request = FactoryBot.build(:request, name: 'test-vm')
        expect(request).to be_valid
      end
    end
  end

  describe 'method tests' do
    let(:request) { FactoryBot.create :request }
    let(:user) { FactoryBot.create :user }

    context 'when accepting a request' do
      it 'changes status to accepted' do
        request.accept!
        expect(request.status).to eq('accepted')
      end
    end

    describe 'assign_sudo_users' do
      it 'creates sudo user assignments correctly' do
        request.assign_sudo_users([user.id])
        expect((request.sudo_user_assignments.select { |assignment| assignment.user_id == user.id }).size).to eq(1)
      end

      it 'does not persist new assignments' do
        request.assign_sudo_users([user.id])
        expect(request.sudo_user_assignments).to all(be_changed)
      end

      it 'persists new assignments when saved' do
        request.assign_sudo_users [user.id]
        request.save!
        request.sudo_user_assignments.each do |each|
          expect(each).not_to be_changed
        end
      end

      context 'with pre-existing sudo assignmnets' do
        let(:user2) { FactoryBot.create :user }

        before do
          request.assign_sudo_users([user.id, user2.id])
          request.save!
        end

        it 'can remove assignments' do
          request.assign_sudo_users([user.id])
          expect(request.sudo_users).to match_array([user])
        end
      end

      context 'if a user should be upgraded' do
        before do
          request.update! users: [user]
          request.assign_sudo_users [user.id]
        end

        it 'can upgrade users' do
          expect(request.sudo_users).to match_array([user])
        end

        it 'does not save upgraded user assignments' do
          expect(request.sudo_user_assignments).to all(be_changed)
        end

        it 'saves upgraded user assignments when saved' do
          request.save!
          request.sudo_user_assignments.each do |each|
            expect(each).not_to be_changed
          end
        end
      end
    end

    context 'when having a non sudo user' do
      before do
        @assignment = request.users_assigned_to_requests.build(user_id: user.id, sudo: false)
      end

      it 'does not return a sudo user' do
        expect(request.sudo_user_assignments.include?(@assignment)).to be false
      end

      it 'does return a non sudo user' do
        expect(request.non_sudo_user_assignments.include?(@assignment)).to be true
      end
    end

    context 'when having a sudo user' do
      before do
        @sudo_assignment = request.users_assigned_to_requests.build(user_id: user.id, sudo: true)
      end

      it 'does return a sudo user' do
        expect(request.sudo_user_assignments.include?(@sudo_assignment)).to be true
      end

      it 'does not return a non sudo user' do
        expect(request.non_sudo_user_assignments.include?(@sudo_assignment)).to be false
      end
    end

    context 'when having a user being assigned as user and sudo user' do
      let(:request) { FactoryBot.create(:request, name: 'myvm1', user_ids: [user.id]) }

      before do
        request.assign_sudo_users([user.id])
      end

      it 'creates a sudo user assignment' do
        expect((request.sudo_user_assignments.select { |assignment| assignment.user_id == user.id && assignment.sudo == true }).size).to eq(1)
      end

      it 'does not create a user assignment' do
        expect(request.users_assigned_to_requests.select { |assignment| assignment.user_id == user.id && assignment.sudo == false }).to be_empty
      end
    end
  end

  describe 'create_vm' do
    let(:request) { FactoryBot.create(:request) }

    it 'saves the responsible users in the VM' do
      request.responsible_users = [FactoryBot.create(:admin)]
      vm = request.create_vm
      expect(vm.responsible_users).to match_array(request.responsible_users)
    end
  end

  describe 'puppet script helper methods' do
    let(:request) { FactoryBot.create(:request_with_users) }

    it 'returns correct declaration script for a given request' do
      script = request.generate_puppet_name_script
      expected_string = <<~NAME_SCRIPT
        node \'$myvm\'{

            if defined( node_$myvm) {
                        class { node_$myvm: }
            }
        }
      NAME_SCRIPT
      expect(script).to eq(expected_string)
    end

    it 'returns correct initialization script for a given request' do
      users = request.users
      email = users[0].email.split('@').first
      email2 = users[1].email.split('@').first
      email3 = users[2].email.split('@').first
      email4 = users[3].email.split('@').first
      script = request.generate_puppet_node_script
      expected_string = <<~NODE_SCRIPT
        class node_$myvm {
                $admins = []
                $users = ["#{email}", "#{email2}", "#{email3}", "#{email4}"]

                realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
                realize(Accounts::Virtual[$users])
        }
      NODE_SCRIPT
      format(expected_string, email, email2, email3, email4)
      expect(script).to eq(expected_string)
    end
  end

  describe 'push to git' do
    let(:request) { FactoryBot.build :request }

    before do
      @git_stub = create_git_stub
    end

    after do
      @git_stub.delete
    end

    it 'correctly calls git' do
      expect(@git_stub.git).to receive(:config).with('user.name', 'test_user_name')
      expect(@git_stub.git).to receive(:config).with('user.email', 'test_user_email')
      request.push_to_git
    end

    context 'with a new puppet script' do
      before do
        allow(@git_stub.status).to receive(:changed).and_return([])
        allow(@git_stub.status).to receive(:added).and_return(['added_file'])
      end

      it 'pushes to git when a vm is created' do
        expect(@git_stub.git).to receive(:commit_all)
        expect(@git_stub.git).to receive(:push)
        request.create_vm
      end

      it 'correctly calls git' do
        request.push_to_git
        expect(@git_stub.git).to have_received(:commit_all).with('Add myvm')
      end
    end

    context 'with a changed puppet script' do
      before do
        allow(@git_stub.status).to receive(:changed).and_return(['changed_file'])
        allow(@git_stub.status).to receive(:added).and_return([])
      end

      it 'correctly calls git' do
        expect(@git_stub.git).to receive(:commit_all).with('Update myvm')
        request.push_to_git
      end
    end

    context 'without any changes' do
      before do
        allow(@git_stub.status).to receive(:changed).and_return([])
        allow(@git_stub.status).to receive(:added).and_return([])
      end

      it 'correctly calls git' do
        expect(@git_stub.git).not_to receive(:commit_all)
        request.push_to_git
      end
    end
  end
end
