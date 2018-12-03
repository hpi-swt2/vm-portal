# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operation_systems/new', type: :view do
  before do
    assign(:operation_system, OperationSystem.new(
                                name: 'MyString'
                              ))
  end

  it 'renders new operation_system form' do
    render

    assert_select 'form[action=?][method=?]', operation_systems_path, 'post' do
      assert_select 'input[name=?]', 'operation_system[name]'
    end
  end
end
