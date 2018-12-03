# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operation_systems/edit', type: :view do
  before do
    @operation_system = assign(:operation_system, OperationSystem.create!(
                                                    name: 'MyString'
                                                  ))
  end

  it 'renders the edit operation_system form' do
    render

    assert_select 'form[action=?][method=?]', operation_system_path(@operation_system), 'post' do
      assert_select 'input[name=?]', 'operation_system[name]'
    end
  end
end
