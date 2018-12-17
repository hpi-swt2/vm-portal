# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/edit', type: :view do
  before do
    @request = assign(:request, Request.create!(
                                  name: 'MyVM',
                                  cpu_cores: 2,
                                  ram_mb: 1000,
                                  storage_mb: 1000,
                                  operating_system: 'MyOS',
                                  port: '4000',
                                  application_name: 'MyName',
                                  description: 'Description',
                                  comment: 'Comment',
                                  status: 'pending'
                                ))
  end

  it 'renders the edit request form' do
    render

    assert_select 'form[action=?][method=?]', request_path(@request), 'post' do
      assert_select 'input[name=?]', 'request[name]'

      assert_select 'input[name=?]', 'request[cpu_cores]'

      assert_select 'input[name=?]', 'request[ram_mb]'

      assert_select 'input[name=?]', 'request[storage_mb]'

      assert_select 'select[name=?]', 'request[operating_system]'

      assert_select 'input[name=?]', 'request[port]'

      assert_select 'input[name=?]', 'request[application_name]'

      assert_select 'textarea[name=?]', 'request[description]'

      assert_select 'textarea[name=?]', 'request[comment]'
    end
  end
end
