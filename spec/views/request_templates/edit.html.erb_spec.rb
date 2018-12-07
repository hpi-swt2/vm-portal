require 'rails_helper'

RSpec.describe "request_templates/edit", type: :view do
  before(:each) do
    @request_template = assign(:request_template, RequestTemplate.create!(
      :cpu_count => 1,
      :ram_mb => 1,
      :storage_mb => 1,
      :operating_system => "MyString"
    ))
  end

  it "renders the edit request_template form" do
    render

    assert_select "form[action=?][method=?]", request_template_path(@request_template), "post" do

      assert_select "input[name=?]", "request_template[cpu_count]"

      assert_select "input[name=?]", "request_template[ram_mb]"

      assert_select "input[name=?]", "request_template[storage_mb]"

      assert_select "input[name=?]", "request_template[operating_system]"
    end
  end
end
