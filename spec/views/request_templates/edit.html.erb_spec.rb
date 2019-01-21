# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'request_templates/edit', type: :view do
  before do
    sign_in FactoryBot.create :user

    @request_template = assign(:request_template, RequestTemplate.create!(
                                                    name: 'myString',
                                                    cpu_cores: 1,
                                                    ram_mb: 1000,
                                                    storage_mb: 1000,
                                                    operating_system: 'MyString'
                                                  ))
  end

  it 'renders the edit request_template form' do
    render

    assert_select 'form[action=?][method=?]', request_template_path(@request_template), 'post' do
      assert_select 'input[name=?]', 'request_template[name]'

      assert_select 'input[name=?]', 'request_template[cpu_cores]'

      assert_select 'input[name=?]', 'request_template[ram_mb]'

      assert_select 'input[name=?]', 'request_template[storage_mb]'

      assert_select 'select[name=?]', 'request_template[operating_system]'
    end
  end
end
