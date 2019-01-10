require 'rails_helper'

RSpec.describe "servers/new", type: :view do
  before(:each) do
    assign(:server, Server.new(
    					name: 'SpecServer',
    					cpu_cores: 4,
    					ram_mb: 1024,
    					storage_mb: 4096,
    					mac_address: 'C0:FF:EE:C4:11:42',
    					fqdn: 'arrrr.speck.de',
    					ipv4_address: '8.8.8.8',
    					ipv6_address: '::1',
    					installed_software: ['SpeckTester'],
    	))
  end

  it "renders new server form" do
    render

    assert_select "form[action=?][method=?]", servers_path, "post" do
    	assert_select 'input[name=?]', 'request[name]'

      	assert_select 'input[name=?][min=?]', 'request[cpu_cores]', '0'

      	assert_select 'input[name=?][min=?]', 'request[ram_mb]', '0'

      	assert_select 'input[name=?][min=?]', 'request[storage_mb]', '0'

      	assert_select 'input[name=?]', 'request[mac_address]'

      	assert_select 'input[name=?]', 'request[fqdn]'

      	assert_select 'input[name=?]', 'request[ipv4_address]'

      	assert_select 'input[name=?]', 'request[ipv6_address]'

      	assert_select 'button[value=?]', 'Add Software'
      	


    end
  end
end
