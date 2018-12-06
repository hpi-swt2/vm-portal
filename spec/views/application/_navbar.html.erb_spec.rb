# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'application/_navbar.html.erb', type: :view do
  before do
    render
  end

  it 'links to server list' do
    expect(rendered).to have_link('Servers', href: '../servers')
  end

  it 'links to vm list' do
    expect(rendered).to have_link('VMs', href: '../vms')
  end
end
