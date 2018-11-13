# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/edit', type: :view do
  before(:each) do
    @request = assign(:request, Request.create!(
      operating_system: 'MyString',
      ram_mb: 1,
      cpu_cores: 1,
      software: 'MyString',
      comment: 'MyString',
      status: 'pending'
    ))
  end

  it 'renders the edit request form' do
    render

    assert_select 'form[action=?][method=?]', request_path(@request), 'post' do

      assert_select 'input[name=?]', 'request[operating_system]'

      assert_select 'input[name=?]', 'request[ram_mb]'

      assert_select 'input[name=?]', 'request[cpu_cores]'

      assert_select 'input[name=?]', 'request[software]'

    end
  end
end
