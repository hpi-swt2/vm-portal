# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperatingSystem, type: :model do
  let(:operating_system) { FactoryBot.build :operating_system }

  context 'when operating_system is invalid' do
    it 'is invalid with no name' do
      operating_system.name = ''
      expect(operating_system).to be_invalid
    end
  end

  context 'when operating_system is valid' do
    it 'is valid with valid parameters' do
      expect(operating_system).to be_valid
    end
  end
end
