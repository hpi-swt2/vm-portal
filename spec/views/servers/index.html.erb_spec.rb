# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/index', type: :view do
  before() do
    assign(:servers, [
             Server.create!(
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
             ),
             Server.create!(
               name: 'SpecServer2',
               cpu_cores: 8,
               ram_gb: 32,
               storage_gb: 2048,
               mac_address: 'C0:FF:EE:C4:11:45',
               fqdn: 'arrrr.speck.pirate',
               ipv4_address: '8.8.8.9',
               ipv6_address: '::2',
               installed_software: ['SpeckTester'],
               responsible: 'Hans Wurst'
             )
           ])
  end

  it 'renders a list of servers' do
    render
  end

  it 'shows new link to admin' do
    assign(:user_is_admin, true)
    render
    expect(rendered).to have_button("New")
  end

  it 'does not show new link per default' do
    render
    expect(rendered).not_to have_button("New")
  end
end
