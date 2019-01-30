# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VmsHelper, type: :helper do
  it 'returns the request to the vm correctly' do
    vm = v_sphere_vm_mock 'testvm'
    request = FactoryBot.create :accepted_request, name: 'testvm'
    expect(request_for(vm).name).to eq(request.name)
  end
end