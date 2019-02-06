# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/edit', type: :view do
  before do
    @request = assign(:request, FactoryBot.create(:request))
    assign(:request_templates, [FactoryBot.create(:request_template)])
  end

  it 'renders the edit request form' do
    render

    assert_select 'form[action=?][method=?]', request_path(@request), 'post' do
      assert_select 'input[name=?]', 'request[name]'

      assert_select 'input[name=?]', 'request[cpu_cores]'

      assert_select 'input[name=?]', 'request[ram_gb]'

      assert_select 'input[name=?]', 'request[storage_gb]'

      assert_select 'select[name=?]', 'request[operating_system]'

      assert_select 'input[name=?]', 'request[port]'

      assert_select 'input[name=?]', 'request[application_name]'

      assert_select 'textarea[name=?]', 'request[description]'

      assert_select 'textarea[name=?]', 'request[comment]'
    end
  end
end
