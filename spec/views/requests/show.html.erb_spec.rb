require 'rails_helper'

RSpec.describe 'requests/show', type: :view do
  before(:each) do
    @request = assign(:request, Request.create!(
      operating_system: 'Operating System',
      ram_mb: 2,
      cpu_cores: 3,
      software: 'Software',
      comment: 'Comment',
      accepted: false
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Operating System/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Software/)
    expect(rendered).to match(/Comment/)
    expect(rendered).to match(/false/)
  end
end
