# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/index', type: :view do
  let(:current_user) { FactoryBot.create :user }
  let(:servers) do
    [Server.create!(
      name: 'SpecServer',
      cpu_cores: 4,
      ram_gb: 1024,
      storage_gb: 4096,
      mac_address: 'C0:FF:EE:C4:11:42',
      fqdn: 'arrrr.speck.de',
      ipv4_address: '8.8.8.8',
      ipv6_address: '::1',
      installed_software: ['SpeckTester'],
      responsible: 'Hans Wurst'),
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
      responsible: 'Hans Wurst')]
  end

  before do
    assign(:servers, servers)
    allow(view).to receive(:current_user).and_return(current_user)
  end

  it 'renders a list of servers' do
    render
  end

  it 'does not show new server button per default' do
    render
    expect(rendered).not_to have_button('New')
  end

  context 'admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'shows new server button to admin' do
      render
      expect(rendered).to have_button('New')
      
    end
  end
end
