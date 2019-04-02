# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Puppetscript do
  let(:path) { File.join('spec', 'lib') }

  before do
    allow(described_class).to receive(:read_node_file).and_call_original
  end

  let!(:user) { FactoryBot.create :puppet_user }
  let!(:admin1) { FactoryBot.create :puppet_admin }
  let!(:admin2) { FactoryBot.create :puppet_admin2 }

  describe 'generate node file' do

    let(:admins) { [admin1, admin2] }
    let(:users) { [user] }
    let(:script) { Puppetscript.node_script 'MyVM', admins, users }

    it 'returns a valid node file' do
      expect(Puppetscript.node_file_correct?('MyVM', script)).to be true
    end

    it 'can read the admins out again' do
      expect(Puppetscript.read_node_string(script)[:admins]).to match_array admins
    end

    it 'can read the users out again' do
      expect(Puppetscript.read_node_string(script)[:users]).to match_array users
    end

  end

  describe 'read valid node file' do
    let(:puppet_file) { Puppetscript.read_node_file('example', path) }

    it 'returns the results as a Hash' do
      expect(puppet_file).to be_a_kind_of Hash
    end

    it 'returns the admins as an Array' do
      admins = puppet_file[:admins]
      expect(admins).to be_a_kind_of Array
    end

    it 'contains 2 admins' do
      admins = puppet_file[:admins]
      expect(admins.count).to eq(2)
    end

    it 'contains the first admin in the admins\' Array' do
      admins = puppet_file[:admins]
      expect(admins).to include(admin1)
    end

    it 'contains the secondadmin in the admins\' Array' do
      admins = puppet_file[:admins]
      expect(admins).to include(admin2)
    end

    it 'returns the users as an Array' do
      users = puppet_file[:users]
      expect(users).to be_a_kind_of Array
    end

    it 'contains 1 user' do
      users = puppet_file[:users]
      expect(users.count).to eq(1)
    end

    it 'contains the first user in the users\' Array' do
      users = puppet_file[:users]
      expect(users).to include(user)
    end

    it 'raises an error if trying to read a puppet file with the node name not matching the file name' do
      expect { Puppetscript.read_node_file('example3', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which admins are not added as sudoroot' do
      expect { Puppetscript.read_node_file('example4', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which admins are not added as virtual user' do
      expect { Puppetscript.read_node_file('example5', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which users are not added as virtual user' do
      expect { Puppetscript.read_node_file('example6', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file with missing class declaration on the first line' do
      expect { Puppetscript.read_node_file('example7', path) }.to raise_error 'Unsupported Format'
    end

    it 'raises an error if trying to read a puppet file with missing closing bracket for the class declaration' do
      expect { Puppetscript.read_node_file('example8', path) }.to raise_error 'Unsupported Format'
    end
  end
end
