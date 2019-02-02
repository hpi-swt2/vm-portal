# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'hosts/show.html.erb', type: :view do
  let(:host) do
    v_sphere_host_mock('lol')
  end

  before do
    assign(:host, host)
    render
  end

  it 'shows host name' do
    expect(rendered).to include host.name
  end

  it 'shows vendor' do
    expect(rendered).to include host.vendor
  end

  it 'shows model' do
    expect(rendered).to include host.model
  end

  it 'shows vms' do
    host.vms.each do |vm|
      expect(rendered).to include vm.name.to_s
    end
  end
end
