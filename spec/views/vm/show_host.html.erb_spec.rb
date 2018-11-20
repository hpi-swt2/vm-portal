require 'rails_helper'

RSpec.describe 'vm/show_host.html.erb', type: :view do
  let(:host) do
    summary = double
    { name: 'aHost', 
      vm_names: ['vm'], 
      model: "a cool model", 
      vendor: "the dark side", 
      bootTime: "Thursday", 
      connectionState: "connected", 
      summary: summary }
  end

  before do
    assign(:host, host)
    render
  end

  it 'shows host name' do
    expect(rendered).to include host[:name]
  end

  it 'shows vendor' do
    expect(rendered).to include host[:vendor]
  end

  it 'shows model' do
    expect(rendered).to include host[:model]
  end

  it 'shows boot time' do
    expect(rendered).to include host[:bootTime]
  end

  it 'shows vms' do
    host[:vm_names].each do |vm|
      expect(rendered).to include vm
    end
  end

end

