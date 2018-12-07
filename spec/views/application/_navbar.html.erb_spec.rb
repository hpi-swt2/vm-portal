# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'application/_navbar.html.erb', type: :view do
  before do
    render
  end

  it 'links to server list' do
    expect(rendered).to have_link('Servers', href: '../server')
  end

  it 'links to vm list' do
    expect(rendered).to have_link('VMs', href: '../vm')
  end

  it 'has logo' do
    expect(rendered).to have_content('logo.svg')
  end
end
