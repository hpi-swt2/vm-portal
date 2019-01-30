# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/index', type: :view do
  let(:requests) do
    [
      Request.create!(
        name: 'myvm',
        cpu_cores: 3,
        ram_mb: 1000,
        storage_mb: 2000,
        operating_system: 'MyOS',
        port: '4000',
        application_name: 'MyName',
        description: 'Description',
        comment: 'Comment',
        status: 'pending',
        user: FactoryBot.create(:employee)
      ),
      Request.create!(
        name: 'myvm1',
        cpu_cores: 3,
        ram_mb: 1000,
        storage_mb: 2000,
        operating_system: 'MyOS',
        port: '4000',
        application_name: 'MyName',
        description: 'Description',
        comment: 'Comment',
        status: 'pending',
        user: FactoryBot.create(:employee)
      )
    ]
  end

  before do
    assign(:requests, requests)
    render
  end

  it 'renders a list of requests' do
    assert_select 'tr>td', text: 'myvm'.to_s, count: 1
    assert_select 'tr>td', text: 'myvm1'.to_s, count: 1
    assert_select 'tr>td', text: 3.to_s, count: 2
    assert_select 'tr>td', text: 1.to_s, count: 2
    assert_select 'tr>td', text: 2.to_s, count: 2
    assert_select 'tr>td', text: 'MyOS'.to_s, count: 2
    assert_select 'tr>td', text: 4000.to_s, count: 2
    assert_select 'tr>td', text: 'MyName'.to_s, count: 2
    assert_select 'tr>td', text: 'Comment'.to_s, count: 2
    assert_select 'tr>td', text: 'pending'.to_s, count: 2
  end

  it 'has a link to edit the request status' do
    expect(rendered).to have_link(href: request_path(requests[0]))
    expect(rendered).to have_link(href: request_path(requests[1]))
  end
end
