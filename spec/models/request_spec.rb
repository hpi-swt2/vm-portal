# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do
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

  context 'when it has a name with whitespaces' do
    it 'replaces them by -' do
      request.name = 'VM Name'
      request.replace_whitespaces
      expect(request.name).to eq('VM-Name')
    end
  end
end
