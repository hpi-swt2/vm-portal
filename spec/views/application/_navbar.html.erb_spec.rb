# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'application/_navbar.html.erb', type: :view do
  context 'the current user is not an admin' do
    let(:current_user) { FactoryBot.create :user }

    before do
      sign_in current_user
      allow(view).to receive(:current_user).and_return(current_user)
      render
    end

    it 'links to host list' do
      expect(rendered).to have_link('Hosts', href: hosts_path)
    end

    it 'links to vm list' do
      expect(rendered).to have_link('VMs', href: vms_path)
    end

    it 'does not link to users list' do
      expect(rendered).not_to have_link('Users', href: users_path)
    end

    it 'links to the current user' do
      expect(rendered).to have_link(current_user.name, href: user_path(current_user))
    end
  end

  context 'the current user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    before do
      sign_in current_user
      allow(view).to receive(:current_user).and_return(current_user)
      render
    end

    it 'links to users list' do
      expect(rendered).to have_link('Users', href: users_path)
    end
  end
end
