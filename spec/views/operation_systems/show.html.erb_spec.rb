# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operation_systems/show', type: :view do
  before do
    @operation_system = assign(:operation_system, OperationSystem.create!(
                                                    name: 'Name'
                                                  ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
  end
end
