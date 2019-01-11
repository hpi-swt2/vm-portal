# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'application/_navbar.html.erb', type: :view do
  let(:current_user) { FactoryBot.create :user }

  before do
    sign_in current_user
    allow(view).to receive(:current_user).and_return(current_user)
    render
  end

  it 'links to dashboard' do
    expect(rendered).to have_link('Dashboard', href: dashboard_path)
  end

  it 'links to vm list' do
    expect(rendered).to have_link('VMs', href: vms_path)
  end

  it 'links to host list' do
    expect(rendered).to have_link('Hosts', href: hosts_path)
  end

  it 'links to user list' do
    expect(rendered).to have_link('Users', href: users_path)
  end

  it 'links to the current user profile' do
    expect(rendered).to have_link('Profile', href: user_path(current_user))
  end

  it 'links to the Notification Page' do
    expect(rendered).to have_link(href: notifications_path)
  end
end
