# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operation_systems/index', type: :view do
  before do
    assign(:operation_systems, [
             OperationSystem.create!(
               name: 'Name'
             ),
             OperationSystem.create!(
               name: 'Name'
             )
           ])
  end

  it 'renders a list of operation_systems' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
  end
end
