# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/new', type: :view do
  before do
    assign(:request, Request.new(
                       name: 'MyVM',
                       cpu_cores: 2,
                       ram_mb: 1000,
                       storage_mb: 2000,
                       operating_system: 'MyOS',
                       comment: 'Comment',
                       status: 'pending'
                     ))
  end

  it 'renders new request form' do
    render
    expect(rendered).to match(/Windows/)

    assert_select 'form[action=?][method=?]', requests_path, 'post' do
      assert_select 'input[name=?]', 'request[name]'

      assert_select 'input[name=?][min=?]', 'request[cpu_cores]', '0'

      assert_select 'input[name=?][min=?]', 'request[ram_mb]', '0'

      assert_select 'input[name=?][min=?]', 'request[storage_mb]', '0'

      assert_select 'select[name=?]', 'request[operating_system]'

      assert_select 'textarea[name=?]', 'request[comment]'
    end
  end
end
