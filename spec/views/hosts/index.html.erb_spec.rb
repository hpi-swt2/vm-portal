# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hosts/index.html.erb', type: :view do
  let(:host) do
    {  name: 'someHostMachine',
       model: 'cool machine',
       vendor: 'nice vendor',
       bootTime: 'some long while',
       connectionState: 'connected',
       vm_names: ['a name', 'another name'] }
  end
  let(:param) do
    %w[up_hosts down_hosts]
  end

  before do
    assign(:hosts, [host])
    assign(:parameters, [param])
    render
  end

  it 'renders the host machine name' do
    expect(rendered).to include host[:name]
  end

  it 'renders model name' do
    expect(rendered).to include host[:model]
  end

  it 'renders vendor name' do
    expect(rendered).to include host[:vendor]
  end

  it 'renders boot time' do
    expect(rendered).to include host[:bootTime]
  end

  it 'renders connectionState' do
    expect(rendered).to include host[:connectionState]
  end

  it 'renders vm names' do
    host[:vm_names].each do |name|
      expect(rendered).to include name
    end
  end

  it 'links to resource detail pages' do
    expect(rendered).to have_link(host[:name], count: 1)
  end

  it 'can filter resources' do
    expect(rendered).to have_button('Filter')
  end

  it 'has reserve button' do
    expect(rendered).to have_button('Reserve')
  end
end
