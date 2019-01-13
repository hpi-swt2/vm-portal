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
        request.cpu_cores = 65
        expect(request).to be_invalid
      end

      it 'is invalid with negative ram specifiation' do
        request.ram_mb = -1
        expect(request).to be_invalid
      end

      it 'is invalid with to much ram' do
        request.ram_mb = 257_000
        expect(request).to be_invalid
      end

      it 'is invalid with negative storage specifiation' do
        request.storage_mb = -1
        expect(request).to be_invalid
      end

      it 'is invalid with to much storage' do
        request.storage_mb = 1_000_000
        expect(request).to be_invalid
      end

      it 'is invalid with no description' do
        request.description = nil
        expect(request).to be_invalid
      end
    end

    context 'when request is valid' do
      it 'is valid with valid attributes' do
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
        @request = FactoryBot.create(:request, user_ids: [@user.id])
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
end
