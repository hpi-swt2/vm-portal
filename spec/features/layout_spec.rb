# frozen_string_literal: true

require 'rails_helper'

describe 'Index page', type: :feature do
  it 'has a navbar' do
    visit root_path
    expect(page).to have_css('nav')
  end

  it 'has content' do
    visit root_path
    expect(page).to have_css('#content')
  end

  it 'has a footer' do
    visit root_path
    expect(page).to have_css('#footer')
  end

end
