# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/new', type: :view do
  before(:each) do
    assign(:server, Server.new(
                      name: 'SpecServer',
                      cpu_cores: 4,
                      ram_gb: 1024,
                      storage_gb: 4096,
                      mac_address: 'C0:FF:EE:C4:11:42',
                      fqdn: 'arrrr.speck.de',
                      ipv4_address: '8.8.8.8',
                      ipv6_address: '::1',
                      installed_software: ['SpeckTester'],
                      responsible: 'Hans Wurst'
                    ))
  end

  it 'renders new server form' do
    render

    assert_select 'form[action=?][method=?]', servers_path, 'post' do
      assert_select 'input[name=?]', 'server[name]'

      assert_select 'input[name=?][min=?]', 'server[cpu_cores]', '0'

      assert_select 'input[name=?][min=?]', 'server[ram_gb]', '0'

      assert_select 'input[name=?][min=?]', 'server[storage_gb]', '0'

      assert_select 'input[name=?]', 'server[mac_address]'

      assert_select 'input[name=?]', 'server[fqdn]'

      assert_select 'input[name=?]', 'server[ipv4_address]'

      assert_select 'input[name=?]', 'server[ipv6_address]'

      assert_select 'input[name=?]', 'server[responsible]'

      expect(rendered).to have_button 'Add Software'
    end
  end
end
