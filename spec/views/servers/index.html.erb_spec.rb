require 'rails_helper'

RSpec.describe "servers/index", type: :view do
  before(:each) do
    assign(:servers, [
      Server.create!(),
      Server.create!()
    ])
  end

  it "renders a list of servers" do
    render
  end
end
