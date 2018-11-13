# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/new', type: :view do
  before(:each) do
    assign(:request, Request.new(
      operating_system: 'MyString',
      ram_mb: 1,
      cpu_cores: 1,
      software: 'MyString',
      comment: 'Comment',
      status: 'pending'
    ))
  end

  it 'renders new request form' do
    render

    assert_select 'form[action=?][method=?]', requests_path, 'post' do

      assert_select 'input[name=?]', 'request[operating_system]'

      assert_select 'input[name=?]', 'request[ram_mb]'

      assert_select 'input[name=?]', 'request[cpu_cores]'

      assert_select 'input[name=?]', 'request[software]'
      
    end
  end
end
