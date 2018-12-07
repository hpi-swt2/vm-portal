require 'rails_helper'

RSpec.describe "request_templates/show", type: :view do
  before(:each) do
    @request_template = assign(:request_template, RequestTemplate.create!(
      :cpu_count => 2,
      :ram_mb => 3,
      :storage_mb => 4,
      :operating_system => "Operating System"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Operating System/)
  end
end
