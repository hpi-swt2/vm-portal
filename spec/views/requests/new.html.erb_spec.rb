# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/new', type: :view do
  before(:each) do
    assign(:request, Request.new(
      name: 'MyVM',
      cpu_cores: 2,
      ram_mb: 1000,
      storage_mb: 2000,
      operating_system: 'MyOS',
      software: 'MySoftware',
      comment: 'Comment',
      status: 'pending'
    ))
  end

  it 'renders new request form' do
    render

    assert_select 'form[action=?][method=?]', requests_path, 'post' do
      assert_select 'input[name=?]', 'request[name]'

      assert_select 'input[name=?]', 'request[cpu_cores]'

      assert_select 'input[name=?]', 'request[ram_mb]'

      assert_select 'input[name=?]', 'request[storage_mb]'

      assert_select 'input[name=?]', 'request[operating_system]'

      assert_select 'input[name=?]', 'request[software]'

      assert_select 'input[name=?]', 'request[comment]'
    end
  end
end
