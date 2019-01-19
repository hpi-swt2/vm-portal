# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/edit.html.erb', type: :view do
  let(:vm) do
    { name: 'VM',
      state: true,
      boot_time: Time.current,
      host: 'aHost',
      guestHeartbeatStatus: 'green',
      vmwaretools: true }
  end

  before do
    assign(:vm, vm)
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm[:name]
  end

  it 'says edit' do
    expect(rendered).to include 'edit'
  end

 
end
