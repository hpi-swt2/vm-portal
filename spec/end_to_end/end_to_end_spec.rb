# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'End to End testing', type: :feature do
  let(:host) do
    v_sphere_host_mock('someHost')
  end

  before do
    @user = FactoryBot.create :user
    @employee = FactoryBot.create :employee
    @admin = FactoryBot.create :admin
    @requestname = 'capybara-test-vm'
    allow(VSphere::Host).to receive(:all).and_return [host]
  end

  describe 'GET "/" - Landing Page'
  it 'has a o-auth log-in button' do
    visit '/'
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_link('Sign in with HPI OpenID Connect')
  end

  describe 'Request Process'
  it 'is possible to request a new VM' do
    sign_in @employee
    visit '/vms/vm'
    click_on 'New Request'
    expect(page).to have_current_path('/vms/requests/new')
    fill_in('VM Name', with: @requestname)
    fill_in('cpu', with: 4)
    fill_in('ram', with: 8)
    fill_in('storage', with: 126)
    select(@employee.email, from: 'request_responsible_user_ids')
    select(@employee.email, from: 'request_sudo_user_ids')
    select(@user.email, from: 'request_user_ids')
    select('none', from: 'operating_system')
    fill_in('Description', with: 'test')
    click_on 'Create Request'
    expect(page).to have_text('Request was successfully created.')
    expect(page).to have_current_path('/vms/requests')
    click_on @requestname
    expect(page.body).to have_text('Request Information')
  end

  it 'is possible to accept a VM request' do
    sign_in @admin
    visit '/vms/vm'
    click_on 'New Request'
    fill_in('VM Name', with: @requestname)
    fill_in('cpu', with: 4)
    fill_in('ram', with: 8)
    fill_in('storage', with: 126)
    select(@admin.email, from: 'request_responsible_user_ids')
    select(@admin.email, from: 'request_sudo_user_ids')
    select(@user.email, from: 'request_user_ids')
    select('none', from: 'operating_system')
    fill_in('Description', with: 'test')
    click_on 'Create Request'
    click_on @requestname
    expect(page).to have_button('acceptButton')
    expect(page).to have_button('rejectButton')

    # click_on 'acceptButton'
    # expect(page).to have_text('Request was successfully updated and the vm was successfully created.')
    # expect(page).to have_text('Editing configuration of VM')
    # fill_in('virtual_machine_config_ip', :with => '123.0.0.23')
    # fill_in('virtual_machine_config_dns', :with => 'www.example.com')
    # click_on 'Update Configuration'
    # expect(page).to have_text('Successfully updated configuration')
    # expect(current_path).to eq('/vms/requests')
    # click_on @requestname
    # expect(page).to have_text('accepted')
    # visit "/vms/#{@requestname}"
    # expect(page).to have_text('offline')
  end

  it 'is possible to turn on a VM' do
    skip
    sign_in @admin
    visit '/vms/vm'
    click_on 'New Request'
    fill_in('VM Name', with: @requestname)
    fill_in('cpu', with: 4)
    fill_in('ram', with: 8)
    fill_in('storage', with: 126)
    select(@admin.email, from: 'request_responsible_user_ids')
    select(@admin.email, from: 'request_sudo_user_ids')
    select(@user.email, from: 'request_user_ids')
    select('none', from: 'operating_system')
    fill_in('Description', with: 'test')
    click_on 'Create Request'
    click_on @requestname
    click_on 'acceptButton'
    page.reload
    fill_in('virtual_machine_config_ip', with: '123.0.0.23')
    fill_in('virtual_machine_config_dns', with: 'www.example.com')
    click_on 'Update Configuration'
    click_on @requestname
    visit "/vms/vm/#{@requestname}"
    expect(page).to have_text('offline')
    select('Power On', from: 'navbarDropdown')
    expect(page).to have_text('online')
  end
end
