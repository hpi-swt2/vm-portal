# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'application/_navbar.html.erb', type: :view do
  before do
    sign_in current_user
    allow(view).to receive(:current_user).and_return(current_user)
    render
  end

  context 'when the current user is not an admin' do
    let(:current_user) { FactoryBot.create :user }

    it 'does not link to host list' do
      expect(rendered).not_to have_link('Hosts', href: hosts_path)
    end

    it 'links to the current user profile' do
      expect(rendered).to have_link('Profile', href: user_path(current_user))
    end

    it 'does not link to servers list' do
      expect(rendered).not_to have_link('Servers', href: servers_path)
    end

    it 'links to the Notification Page' do
      expect(rendered).to have_link(href: notifications_path)
    end

    it 'links to vm list' do
      expect(rendered).to have_link('VMs', href: vms_path)
    end

    it 'links to the project list' do
      expect(rendered).to have_link('Projects', href: projects_path)
    end

    it 'does not link to users list' do
      expect(rendered).not_to have_link('Users', href: users_path)
    end
  end

  context 'when the current user is an employee' do
    let(:current_user) { FactoryBot.create :employee }

    it 'does not link to host list' do
      expect(rendered).not_to have_link('Hosts', href: hosts_path)
    end

    it 'links to the current user profile' do
      expect(rendered).to have_link('Profile', href: user_path(current_user))
    end

    it 'links to the Notification Page' do
      expect(rendered).to have_link(href: notifications_path)
    end

    it 'links to vm list' do
      expect(rendered).to have_link('VMs', href: vms_path)
    end

    it 'links to the project list' do
      expect(rendered).to have_link('Projects', href: projects_path)
    end

    it 'does not link to users list' do
      expect(rendered).not_to have_link('Users', href: users_path)
    end

    it 'links to servers list' do
      expect(rendered).to have_link('Servers', href: servers_path)
    end
  end

  context 'when the current user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'links to users list' do
      expect(rendered).to have_link('Users', href: users_path)
    end

    it 'links to host list' do
      expect(rendered).to have_link('Hosts', href: hosts_path)
    end
  end
end
