# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VirtualMachineConfig, type: :model do

  let(:config) { FactoryBot.create(:virtual_machine_config) }

  it 'can save responsible users' do
    responsible_users = [FactoryBot.create(:admin)]
    config.responsible_users = responsible_users
    config.save!
    expect(config.responsible_users).to match_array(responsible_users)
  end
end
