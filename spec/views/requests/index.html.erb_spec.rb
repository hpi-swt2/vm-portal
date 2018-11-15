# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/index', type: :view do
  before(:each) do
    assign(:requests, [
      Request.create!(
        name: 'MyVM',
        cpu_cores: 2,
        ram_mb: 1000,
        storage_mb: 2000,
        operating_system: 'MyOS',
        software: 'MySoftware',
        comment: 'Comment',
        status: 'pending'
      ),
      Request.create!(
        name: 'MyVM',
        cpu_cores: 2,
        ram_mb: 1000,
        storage_mb: 2000,
        operating_system: 'MyOS',
        software: 'MySoftware',
        comment: 'Comment',
        status: 'pending'
      )
    ])
  end

  it 'renders a list of requests' do
    render
    assert_select 'tr>td', text: 'MyVM'.to_s, count: 2
    assert_select 'tr>td', text: 2.to_s, count: 2
    assert_select 'tr>td', text: 1000.to_s, count: 2
    assert_select 'tr>td', text: 2000.to_s, count: 2
    assert_select 'tr>td', text: 'MyOS'.to_s, count: 2
    assert_select 'tr>td', text: 'MySoftware'.to_s, count: 2
    assert_select 'tr>td', text: 'Comment'.to_s, count: 2
    assert_select 'tr>td', text: 'pending'.to_s, count: 2
  end
end
