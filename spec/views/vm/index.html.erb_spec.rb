# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vm/index.html.erb', type: :view do
  let(:vm) do
    {
        name: 'My insanely cool vm',
        state: true,
        boot_time: 'Yesterday'
    }
  end

  before :each do
    assign(:vms, [vm])
    render
  end

  it 'renders the vms name' do
    expect(rendered).to include vm[:name]
  end

  it 'renders the boot time' do
    expect(rendered).to include vm[:boot_time]
  end
end
