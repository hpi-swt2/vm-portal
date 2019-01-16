# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PuppetParserHelper, type: :helper do
  describe 'Puppet Parser' do
    it "reads a puppet file and parses it's arguments into an array" do
      file = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example.pp')
      puppet_file = PuppetParserHelper.readNodeFile(file)
      admins = puppet_file.admins
      users = puppet_file.users

      expect(puppet_file).to be_a_kind_of Dictionary

      expect(admins).to be_a_kind_of Array
      expect(admins.count).to eq(2)
      expect(admins[0]).to eq("Vorname.Nachname")
      expect(admins[1]).to eq("weitererVorname.Nachname")

      expect(users).to be_a_kind_of Array
      expect(users[1]).to eq("andererVorname.Nachname")
    end

    it "raises an error if trying to read a puppet file which does not contain admins" do
      file = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example2.pp')
      expect(PuppetParser.readNodeFile(file)).to raise_error
    end

    it "raises an error if trying to read a puppet file with syntax errors" do
      # syntax errors include: - file name not matching node name, example3
      #                        - missing class declaration on first line, example7
      #                        - missing closing bracket for class declaration, example8
      file = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example3.pp')
      expect(PuppetParser.readNodeFile(file)).to raise_error
      file2 = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example7.pp')
      expect(PuppetParser.readNodeFile(file2)).to raise_error
      file3 = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example8.pp')
      expect(PuppetParser.readNodeFile(file3)).to raise_error
    end

    it "raises an error if trying to read a puppet file in which admins are not added as sudoroot or virtual user" do
      file = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example4.pp')
      expect(PuppetParser.readNodeFile(file)).to raise_error

      file2 = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example5.pp')
      expect(PuppetParser.readNodeFile(file2)).to raise_error
    end

    it "raises an error if trying to read a puppet file in which users are not added as virtual user" do
      file = File.join(Rails.root, 'spec', 'helpers', 'files', 'node-example6.pp')
      expect(PuppetParser.readNodeFile(file)).to raise_error
    end
  end
end
