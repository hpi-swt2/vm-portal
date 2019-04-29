# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/index', type: :view do
  let(:requests) do
    [FactoryBot.create(:request, name: 'myvm0'), FactoryBot.create(:request, name: 'myvm1')]
  end

  let :resolved_requests do
    [FactoryBot.create(:request, name: 'myvm2'), FactoryBot.create(:request, name: 'myvm3')]
  end

  before do
    sign_in FactoryBot.create :employee
    assign(:pending_requests, requests)
    assign(:resolved_requests, resolved_requests)
    render
  end

  it 'renders a list of all requests' do
    (requests + resolved_requests).each do |each|
      assert_select 'tr>td', text: each.name, count: 1
    end
  end

  it 'renders the attributes of all requests' do
    assert_select 'tr>td', text: 2.to_s, count: 4
    assert_select 'tr>td', text: '1 GB', count: 4
    assert_select 'tr>td', text: '3 GB', count: 4
    assert_select 'tr>td', text: 'MyOS'.to_s, count: 4
    assert_select 'tr>td', text: 4000.to_s, count: 4
    assert_select 'tr>td', text: 'MyName'.to_s, count: 4
    assert_select 'tr>td', text: 'Comment'.to_s, count: 4
  end

  it 'has a link to edit the request status' do
    (requests + resolved_requests).each do |each|
      expect(rendered).to have_link(href: request_path(each))
    end
  end
end
