# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vms/edit.html.erb', type: :view do
  let(:configuration) { FactoryBot.create :virtual_machine_config }

  let(:current_user) { FactoryBot.create :user }

  before do
    sign_in current_user
    assign(:configuration, configuration)
    render
  end

  it 'shows vm name' do
    expect(rendered).to have_text configuration.name
  end

  it 'says edit' do
    expect(rendered).to have_text 'Edit'
  end

  it 'has a button to save' do
    expect(rendered).to have_button 'Update VM information'
  end
end
