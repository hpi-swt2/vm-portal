# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hosts/index.html.erb', type: :view do
  let(:host) do
    host = double
    allow(host).to receive(:name).and_return('someHostMachine')
    allow(host).to receive(:model).and_return('cool machine')
    allow(host).to receive(:vendor).and_return('nice vendor')
    allow(host).to receive(:connection_state).and_return('connected')
    host
  end

  let(:current_user) { FactoryBot.create :user }

  before do
    assign(:hosts, [host])
    allow(view).to receive(:current_user).and_return(current_user)
    render
  end

  it 'renders the host machine name' do
    expect(rendered).to include host.name
  end

  it 'renders model name' do
    expect(rendered).to include host.model
  end

  it 'renders vendor name' do
    expect(rendered).to include host.vendor
  end

  it 'renders connectionState' do
    expect(rendered).to include host.connection_state
  end

  it 'links to resource detail pages' do
    expect(rendered).to have_link(host.name, count: 1)
  end

  it 'does not show new server button per default' do
    expect(rendered).not_to have_button('New')
  end
end
