# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/edit.html.erb', type: :view do
  let(:request) { FactoryBot.build :accepted_request }

  let(:vm) do
    { id: 1,
      name: request.name,
      state: true,
      boot_time: Time.current,
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      vmwaretools: true }
  end

  before do
    assign(:vm, vm)
    assign(:request, request)
    render
  end

  it 'shows vm name' do
    expect(rendered).to have_text vm[:name]
  end

  it 'says edit' do
    expect(rendered).to have_text 'Edit'
  end

end
