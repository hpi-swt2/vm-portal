# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Server, type: :model do
  let(:server) { FactoryBot.build :server }

  context 'when server is invalid' do
    it 'is invalid with no name' do
      server.name = ''
      expect(server).to be_invalid
    end

    it 'is invalid with no cpu_cores specifiation' do
      server.cpu_cores = nil
      expect(server).to be_invalid
    end

    it 'is invalid with no ram specifiation' do
      server.ram_gb = nil
      expect(server).to be_invalid
    end

    it 'is invalid with no storage specifiation' do
      server.storage_gb = nil
      expect(server).to be_invalid
    end

    it 'is invalid with no responsible person' do
      server.responsible = nil
      expect(server).to be_invalid
    end

    it 'is invalid with negative cpu_cores specifiation' do
      server.cpu_cores = -1
      expect(server).to be_invalid
    end

    it 'is invalid with negative ram specifiation' do
      server.ram_gb = -1
      expect(server).to be_invalid
    end

    it 'is invalid with negative storage specifiation' do
      server.storage_gb = -1
      expect(server).to be_invalid
    end

    it 'is invalid with invalid ipv4 address' do
      server.ipv4_address = '192.168.5O.100'
      expect(server).to be_invalid
    end

    it 'is invalid with invalid ipv4 address' do
      server.ipv4_address = '192.168.50'
      expect(server).to be_invalid
    end

    it 'is invalid with invalid ipv4 address' do
      server.ipv4_address = 'ad:aasdf:ad:ad:ad:ad:ad'
      expect(server).to be_invalid
    end

    it 'is invalid with invalid ipv4 address' do
      server.ipv4_address = '::'
      expect(server).to be_invalid
    end

    it 'is invalid with invalid ipv4 address' do
      server.mac_address = '192.168.5O.100'
      expect(server).to be_invalid
    end

    it 'is invalid with invalid mac address' do
      server.mac_address = 'ad:ad:ad.ad:ad:ad'
      expect(server).to be_invalid
    end

    it 'is invalid if name is duplicated' do
      FactoryBot.create :server, name: server.name
      expect(server).to be_invalid
    end
  end

  context 'when server is valid' do
    it 'is valid with valid attributes' do
      expect(server).to be_valid
    end
  end
end
