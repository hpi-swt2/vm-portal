require 'rails_helper'

describe "Index page", :type => :feature do

  it "should have a navbar" do
    visit root_path
    expect(page).to have_css("nav")
  end

  it "should have content" do
    visit root_path
    expect(page).to have_css("#content")
  end

  it "should have a footer" do
    visit root_path
    expect(page).to have_css("#footer")
  end
end