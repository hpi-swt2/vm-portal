# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/edit', type: :view do
  before do
    @server = assign(:server1, Server.create!(
                                 name: 'SpecServer',
                                 cpu_cores: 4,
                                 ram_gb: 1024,
                                 storage_gb: 4096,
                                 mac_address: 'C0:FF:EE:C4:11:42',
                                 fqdn: 'arrrr.speck.de',
                                 ipv4_address: '8.8.8.8',
                                 ipv6_address: '::1',
                                 installed_software: ['SpeckTester']
                               ))
  end

  it 'renders the edit server form' do
    render

    assert_select 'form[action=?][method=?]', server_path(@server), 'post' do
    end
  end
end
