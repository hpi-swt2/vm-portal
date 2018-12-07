require 'rails_helper'

RSpec.describe "request_templates/new", type: :view do
  before(:each) do
    assign(:request_template, RequestTemplate.new(
      :cpu_count => 1,
      :ram_mb => 1,
      :storage_mb => 1,
      :operating_system => "MyString"
    ))
  end

  it "renders new request_template form" do
    render

    assert_select "form[action=?][method=?]", request_templates_path, "post" do

      assert_select "input[name=?]", "request_template[cpu_count]"

      assert_select "input[name=?]", "request_template[ram_mb]"

      assert_select "input[name=?]", "request_template[storage_mb]"

      assert_select "input[name=?]", "request_template[operating_system]"
    end
  end
end
