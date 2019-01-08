# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operating_systems/index', type: :view do
  before do
    assign(:operating_systems, [
             OperatingSystem.create!(
               name: 'Name1'
             ),
             OperatingSystem.create!(
               name: 'Name2'
             )
           ])
  end

  it 'renders a list of operating_systems' do
    render
    assert_select 'tr>td', text: 'Name1'.to_s
    assert_select 'tr>td', text: 'Name2'.to_s
  end
end
