# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PuppetParserHelper, type: :helper do
  describe 'read_node_file' do
    let (:path) { File.join('spec', 'helpers') }

    it 'reads a puppet file and parses it\'s arguments into an array' do
      user = FactoryBot.create :puppet_user
      admin1 = FactoryBot.create :puppet_admin
      admin2 = FactoryBot.create :puppet_admin2
      puppet_file = PuppetParserHelper.read_node_file('example', path)
      admins = puppet_file['admins']
      users = puppet_file['users']
      expect(puppet_file).to be_a_kind_of Hash

      expect(admins).to be_a_kind_of Array
      expect(admins.count).to eq(2)
      expect(admins.first).to include(admin1)
      expect(admins.first).to include(admin2)

      expect(users).to be_a_kind_of Array
      expect(users.first).to include(user)
    end

    it 'raises an error if trying to read a puppet file which does not contain admins' do
      expect { PuppetParserHelper.read_node_file('example2', path) }.to raise_error 'unsupported Format'
    end

    # syntax errors include: - file name not matching node name, example3
    #                        - missing class declaration on first line, example7
    #                        - missing closing bracket for class declaration, example8
    it 'raises an error if trying to read a puppet file with syntax errors' do
      expect { PuppetParserHelper.read_node_file('example3', path) }.to raise_error 'unsupported Format'
      expect { PuppetParserHelper.read_node_file('example7', path) }.to raise_error 'unsupported Format'
      expect { PuppetParserHelper.read_node_file('example8', path) }.to raise_error 'unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which admins are not added as sudoroot or virtual user' do
      expect { PuppetParserHelper.read_node_file('example4', path) }.to raise_error 'unsupported Format'
      expect { PuppetParserHelper.read_node_file('example5', path) }.to raise_error 'unsupported Format'
    end

    it 'raises an error if trying to read a puppet file in which users are not added as virtual user' do
      expect { PuppetParserHelper.read_node_file('example6', path) }.to raise_error 'unsupported Format'
    end
  end
end
