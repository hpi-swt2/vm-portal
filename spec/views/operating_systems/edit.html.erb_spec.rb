# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operating_systems/edit', type: :view do
  before do
    @operating_system = assign(:operating_system, OperatingSystem.create!(
                                                    name: 'MyString'
                                                  ))
  end

  it 'renders the edit operating_system form' do
    render

    assert_select 'form[action=?][method=?]', operating_system_path(@operating_system), 'post' do
      assert_select 'input[name=?]', 'operating_system[name]'
    end
  end
end
