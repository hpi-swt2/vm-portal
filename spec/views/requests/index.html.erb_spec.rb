# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/index', type: :view do
  let(:requests) do
    [FactoryBot.create(:request), FactoryBot.create(:request, name: 'myvm1')]
  end

  before do
    sign_in FactoryBot.create :admin
    assign(:pending_requests, requests)
    assign(:resolved_requests, requests)
    render
  end

  it 'renders a list of all requests' do
    assert_select 'tr>td', text: 'myvm'.to_s, count: 2
    assert_select 'tr>td', text: 'myvm1'.to_s, count: 2
    assert_select 'tr>td', text: 2.to_s, count: 4
    assert_select 'tr>td', text: '1 GB', count: 4
    assert_select 'tr>td', text: '3 GB', count: 4
    assert_select 'tr>td', text: 'MyOS'.to_s, count: 4
    assert_select 'tr>td', text: 4000.to_s, count: 4
    assert_select 'tr>td', text: 'MyName'.to_s, count: 4
    assert_select 'tr>td', text: 'Comment'.to_s, count: 4
  end

  it 'has a link to edit the request status' do
    expect(rendered).to have_link(href: request_path(requests[0]))
    expect(rendered).to have_link(href: request_path(requests[1]))
  end
end

RSpec.describe 'requests/index', type: :view do
  let(:requests) do
    [FactoryBot.create(:request), FactoryBot.create(:request, name: 'myvm1')]
  end

  before do
    sign_in FactoryBot.create :employee
    assign(:pending_requests, requests)
    assign(:resolved_requests, requests)
    render
  end

  it 'renders a list of all requests' do
    assert_select 'tr>td', text: 'myvm'.to_s, count: 2
    assert_select 'tr>td', text: 'myvm1'.to_s, count: 2
    assert_select 'tr>td', text: 2.to_s, count: 4
    assert_select 'tr>td', text: '1 GB', count: 4
    assert_select 'tr>td', text: '3 GB', count: 4
    assert_select 'tr>td', text: 'MyOS'.to_s, count: 4
    assert_select 'tr>td', text: 4000.to_s, count: 4
    assert_select 'tr>td', text: 'MyName'.to_s, count: 4
    assert_select 'tr>td', text: 'Comment'.to_s, count: 4
  end

  it 'has a link to edit the request status' do
    expect(rendered).to have_link(href: request_path(requests[0]))
    expect(rendered).to have_link(href: request_path(requests[1]))
  end
end
