require 'rails_helper'

RSpec.describe "servers/index", type: :view do
  before(:each) do
    assign(:servers, [
      Server.create!(
    					name: 'SpecServer',
    					cpu_cores: 4,
    					ram_mb: 1024,
    					storage_mb: 4096,
    					mac_address: 'C0:FF:EE:C4:11:42',
    					fqdn: 'arrrr.speck.de',
    					ipv4_address: '8.8.8.8',
    					ipv6_address: '::1',
    					installed_software: ['SpeckTester'],
    				),
      Server.create!(
    					name: 'SpecServer',
    					cpu_cores: 4,
    					ram_mb: 1024,
    					storage_mb: 4096,
    					mac_address: 'C0:FF:EE:C4:11:42',
    					fqdn: 'arrrr.speck.de',
    					ipv4_address: '8.8.8.8',
    					ipv6_address: '::1',
    					installed_software: ['SpeckTester'],
    				)
    ])
  end

  it "renders a list of servers" do
    render
  end
end
