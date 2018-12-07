require 'rails_helper'

RSpec.describe "request_templates/index", type: :view do
  before(:each) do
    assign(:request_templates, [
      RequestTemplate.create!(
        :cpu_count => 2,
        :ram_mb => 3,
        :storage_mb => 4,
        :operating_system => "Operating System"
      ),
      RequestTemplate.create!(
        :cpu_count => 2,
        :ram_mb => 3,
        :storage_mb => 4,
        :operating_system => "Operating System"
      )
    ])
  end

  it "renders a list of request_templates" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Operating System".to_s, :count => 2
  end
end
