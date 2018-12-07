# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operating_systems/index', type: :view do
  before do
    assign(:operating_systems, [
             OperatingSystem.create!(
               name: 'Name'
             ),
             OperatingSystem.create!(
               name: 'Name'
             )
           ])
  end

  it 'renders a list of operating_systems' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
  end
end
