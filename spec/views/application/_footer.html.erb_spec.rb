# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'application/_footer.html.erb', type: :view do
  before do
    render
  end

  it 'links to HPI EPIC Website' do
    expect(rendered).to have_link('HPI EPIC', href: 'https://hpi.de/plattner/home.html')
  end

  it 'links to HPI Imprint' do
    expect(rendered).to have_link('Legal Notice', href: 'https://hpi.de/en/impressum.html')
  end
end
