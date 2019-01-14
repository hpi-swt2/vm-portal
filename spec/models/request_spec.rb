# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do
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
  end

  context 'when request is valid' do
    it 'is valid with valid attributes' do
      expect(request).to be_valid
    end
  end

  it 'changes status to accepted' do
    request.accept!
    expect(request.status).to eq('accepted')
  end

  context 'push to git' do
    before do
      @git = double
      @status = double
      allow(@git).to receive(:config).with('user.name', 'test_user_name')
      allow(@git).to receive(:config).with('user.email', 'test_user_email')
      allow(@git).to receive(:status) { @status }
      allow(@git).to receive(:add)
      allow(@git).to receive(:commit_all)
      allow(@git).to receive(:push)

      file = double('file')
      allow(File).to receive(:open) { file }
      allow(file).to receive(:write)

      git_class = class_double('Git')
                  .as_stubbed_const(transfer_nested_constants: true)

      allow(git_class).to receive(:clone) { @git }
    end

    context 'with a new puppet script' do
      before do
        allow(@status).to receive(:untracked).and_return([])
        allow(@status).to receive(:changed).and_return([])
        allow(@status).to receive(:added).and_return(['added_file'])
      end

      it 'correctly calls git' do
        expect(@git).to receive(:config).with('user.name', 'test_user_name')
        expect(@git).to receive(:config).with('user.email', 'test_user_email')
        expect(@git).to(receive(:status).twice) { @status }
        expect(@status).to receive(:untracked).once
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
        allow(@status).to receive(:untracked).and_return([])
        allow(@status).to receive(:changed).and_return(['changed_file'])
        allow(@status).to receive(:added).and_return([])
      end

      it 'correctly calls git' do
        expect(@git).to receive(:config).with('user.name', 'test_user_name')
        expect(@git).to receive(:config).with('user.email', 'test_user_email')
        expect(@git).to(receive(:status).exactly(4).times) { @status }
        expect(@status).to receive(:untracked).twice
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
        allow(@status).to receive(:untracked).and_return([])
        allow(@status).to receive(:changed).and_return([])
        allow(@status).to receive(:added).and_return([])
      end

      it 'correctly calls git' do
        expect(@git).to receive(:config).with('user.name', 'test_user_name')
        expect(@git).to receive(:config).with('user.email', 'test_user_email')
        expect(@git).to(receive(:status).exactly(4).times) { @status }
        expect(@status).to receive(:untracked).twice
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
