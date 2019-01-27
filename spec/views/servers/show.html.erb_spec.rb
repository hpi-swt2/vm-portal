# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'servers/show', type: :view do
  let(:current_user) { FactoryBot.create :user }
  let :server_values do
    { name: 'SpecServer',
      cpu_cores: 4,
      ram_gb: 1024,
      storage_gb: 4096,
      mac_address: 'C0:FF:EE:C4:11:42',
      fqdn: 'arrrr.speck.de',
      ipv4_address: '8.8.8.8',
      ipv6_address: '::1',
      model: 'Blade Center xyz',
      vendor: 'IBM',
      description: 'How to serve men',
      responsible: FactoryBot.create(:admin),
      installed_software: ['SpeckTester'] }
  end

  before do
    assign(:server, Server.create!(server_values))
    allow(view).to receive(:current_user).and_return(current_user)
    render
  end

  it 'renders attributes' do
    server_values.values.each do |value|
      if value.class == Array
        value.each do |element|
          expect(rendered).to include(element.to_s)
        end
      elsif value.class == User
        expect(rendered).to include(value.name)
      else
        expect(rendered).to include(value.to_s)
      end
    end
  end

  it 'does not show delete and edit links per default' do
    expect(rendered).not_to have_link 'Delete'
    expect(rendered).not_to have_link 'Edit'
  end

  context 'admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'shows delete and edit links to admin' do
      render
      expect(rendered).to have_link 'Delete'
      expect(rendered).to have_link 'Edit'
    end
  end
end
