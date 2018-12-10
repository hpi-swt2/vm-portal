# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'templates/_resource_allocation.html.erb', type: :view do

  let(:proper_values) do 
    { cpu_allocation: 100, 
      cpu_usage: 50, 
      ram_allocation: 2, 
      ram_usage: 1, 
      hdd_usage: 50, 
      hdd_allocation: 100, 
      cpu_cores: 2 }
  end

  let(:zero_values) do 
    { cpu_allocation: 0, 
      cpu_usage: 0, 
      ram_allocation: 0, 
      ram_usage: 0, 
      hdd_usage: 0, 
      hdd_allocation: 0, 
      cpu_cores: 0 }
  end

  before do
    assign(:values, proper_values)
    render
  end

  it 'shows CPU usage' do
    expect(rendered).to include (proper_values[:cpu_usage] / proper_values[:cpu_allocation]).round.to_s
  end

  it 'shows HDD usage' do
    expect(rendered).to include proper_values[:hdd_allocation].to_s
    expect(rendered).to include proper_values[:hdd_usage].to_s
    expect(rendered).to include (proper_values[:hdd_usage] / proper_values[:hdd_allocation]).round.to_s
 
  end

  it 'shows RAM usage' do
    expect(rendered).to include proper_values[:ram_allocation].to_s
    expect(rendered).to include proper_values[:ram_usage].to_s
    expect(rendered).to include (proper_values[:ram_usage] / proper_values[:ram_allocation]).round.to_s
  end

  it 'shows CPU cores' do
    expect(rendered).to include proper_values[:cpu_cores].to_s
  end

  it 'allows values to be zero' do
    assign(:values, zero_values)
    render
  end
end
