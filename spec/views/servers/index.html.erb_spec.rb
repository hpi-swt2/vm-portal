# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/index', type: :view do
  let(:current_user) { FactoryBot.create :user }
  let :server_params_1 do
    {
      name: 'SpecServer',
      cpu_cores: 4,
      ram_gb: 1024,
      storage_gb: 4096,
      vendor: 'IBM',
      model: 'a model',
      mac_address: 'C0:FF:EE:C4:11:42',
      fqdn: 'arrrr.speck.de',
      ipv4_address: '8.8.8.8',
      ipv6_address: '::1',
      installed_software: ['SpeckTester'],
      responsible: FactoryBot.create(:admin)
    }
  end

  let :server_params_2 do
    {
      name: 'SpecServer2',
      cpu_cores: 8,
      ram_gb: 32,
      storage_gb: 2048,
      vendor: 'the dark side',
      model: 'death star',
      mac_address: 'C0:FF:EE:C4:11:45',
      fqdn: 'arrrr.speck.pirate',
      ipv4_address: '8.8.8.9',
      ipv6_address: '::2',
      installed_software: ['SpeckTester'],
      responsible: FactoryBot.create(:admin)
    }
  end

  let(:servers) do
    [Server.create!(server_params_1), Server.create!(server_params_2)]
  end

  before do
    assign(:servers, servers)
    allow(view).to receive(:current_user).and_return(current_user)
    render
  end

  it 'renders a list of servers' do
  end

  it 'contains important information' do
    [server_params_1, server_params_2].each do |server|
      expect(rendered).to include(server[:name])
      expect(rendered).to include(server[:model])
      expect(rendered).to include(server[:vendor])
      expect(rendered).to include(server[:responsible].name)
    end
  end

  it 'does not show new server button per default' do
    expect(rendered).not_to have_css('a i.fa-plus')
  end

  context 'admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'shows new server button to admin' do
      render
      expect(rendered).to have_css('a i.fa-plus')
    end
  end
end
