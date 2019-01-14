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
      git = double()
      status = double()
      expect(git).to receive(:config).with('user.name', 'test_user_name')
      expect(git).to receive(:config).with('user.email', 'test_user_email')
      expect(git).to receive(:status).exactly(3).times {status}
      expect(status).to receive(:untracked) {[]}
      expect(status).to receive(:changed) {[]}
      expect(status).to receive(:added) {['added_file']}
      expect(git).to receive(:add)
      expect(git).to receive(:commit_all)
      expect(git).to receive(:push)

      file = double('file')
      File.should_receive(:open).and_yield(file)
      expect(file).to receive(:write)

      git_class = class_double("Git").
          as_stubbed_const(:transfer_nested_constants => true)

      expect(git_class).to receive(:clone) do
        git
      end
    end

    it 'returns a success message' do
      expect(request.push_to_git).to eq({notice: "Successfully pushed to git."})
    end
  end
end
