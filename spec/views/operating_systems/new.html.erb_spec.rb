# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operating_systems/new', type: :view do
  before do
    assign(:operating_system, OperatingSystem.new(
                                name: 'MyString'
                              ))
  end

  it 'renders new operating_system form' do
    render

    assert_select 'form[action=?][method=?]', operating_systems_path, 'post' do
      assert_select 'input[name=?]', 'operating_system[name]'
    end
  end
end
