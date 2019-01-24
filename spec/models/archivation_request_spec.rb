# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArchivationRequest, type: :model do
  let(:archivation_request) do
    ArchivationRequest.create name: 'VM'
  end

  it 'cannot be executed before 3 days' do
    expect(archivation_request.can_be_executed?).to eq false
  end

  it 'can be executed after 3 days' do
    archivation_request.created_at -= 60 * 60 * 24 * 3
    expect(archivation_request.can_be_executed?).to eq true
  end
end
