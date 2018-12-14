require 'rails_helper'

RSpec.describe "servers/show", type: :view do
  before(:each) do
    @server = assign(:server, Server.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
