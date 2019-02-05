# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PuppetParserHelper, type: :helper do
  let(:path) { File.join('spec', 'helpers') }

  before do
    allow(PuppetParserHelper).to receive(:read_node_file).and_call_original
  end

  describe 'read valid node file' do
    let(:user) { FactoryBot.create :puppet_user }
    let(:admin1) { FactoryBot.create :puppet_admin }
    let(:admin2) { FactoryBot.create :puppet_admin2 }
    let(:puppet_file) { PuppetParserHelper.read_node_file('example', path) }

    it 'returns the results as a Hash' do
      expect(puppet_file).to be_a_kind_of Hash
    end

    it 'returns the admins as an Array' do
      admins = puppet_file['admins']
      expect(admins).to be_a_kind_of Array
    end

    it 'contains 2 admins' do
      admins = puppet_file['admins']
      expect(admins.count).to eq(2)
    end

    it 'contains the first admin in the admins\' Array' do
      admins = puppet_file['admins'].first
      expect(admins).to include(admin1)
    end

    it 'contains the secondadmin in the admins\' Array' do
      admins = puppet_file['admins'].first
      expect(admins).to include(admin2)
    end

    it 'returns the users as an Array' do
      users = puppet_file['users']
      expect(users).to be_a_kind_of Array
    end

    it 'contains 1 user' do
      users = puppet_file['users']
      expect(users.count).to eq(1)
    end

    it 'contains the first user in the users\' Array' do
      users = puppet_file['users'].first
      expect(users).to include(user)
    end

    it 'raises an error if trying to read a puppet file which does not contain admins' do
      expect { PuppetParserHelper.read_node_file('example2', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file with the node name not matching the file namne' do
      expect { PuppetParserHelper.read_node_file('example3', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which admins are not added as sudoroot' do
      expect { PuppetParserHelper.read_node_file('example4', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which admins are not added as virtual user' do
      expect { PuppetParserHelper.read_node_file('example5', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which users are not added as virtual user' do
      expect { PuppetParserHelper.read_node_file('example6', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file with missing class declaration on the first line' do
      expect { PuppetParserHelper.read_node_file('example7', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file with missing closing bracket for the class declaration' do
      expect { PuppetParserHelper.read_node_file('example8', path) }.to raise_error 'Unsupported Format'
    end
  end
end
