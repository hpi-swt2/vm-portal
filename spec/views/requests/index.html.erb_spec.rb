# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/index', type: :view do
  before(:each) do
    assign(:requests, [
      Request.create!(
        operating_system: 'Operating System',
        ram_mb: 2,
        cpu_cores: 3,
        software: 'Software',
        comment: 'Comment',
        accepted: false
      ),
      Request.create!(
        operating_system: 'Operating System',
        ram_mb: 2,
        cpu_cores: 3,
        software: 'Software',
        comment: 'Comment',
        accepted: false
      )
    ])
  end

  it 'renders a list of requests' do
    render
    assert_select 'tr>td', text: 'Operating System'.to_s, count: 2
    assert_select 'tr>td', text: 2.to_s, count: 2
    assert_select 'tr>td', text: 3.to_s, count: 2
    assert_select 'tr>td', text: 'Software'.to_s, count: 2
    assert_select 'tr>td', text: 'Comment'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
