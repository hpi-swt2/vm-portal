# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vm/new.html.erb', type: :view do
  before :each do
    render
  end
  it 'has input field for name' do
    expect(rendered).to have_selector 'form input[name="name"]'
  end

  it 'has input field for cpu' do
    expect(rendered).to have_selector 'form input[name="cpu"]'
  end


  it 'has input field for ram' do
    expect(rendered).to have_selector 'form input[name="ram"]'
  end

  it 'has input field for capacity' do
    expect(rendered).to have_selector 'form input[name="capacity"]'
  end

  it 'has a submit button' do
    expect(rendered).to have_button 'Create VM'
  end
end
