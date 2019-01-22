# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/index', type: :view do
  before(:each) do
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
             )
           ])
  end

  it 'renders a list of servers' do
    render
  end
end
