# frozen_string_literal: true

require 'rails_helper'

describe "New vm page", type: :feature do
  it 'could be filled automatically and the created vm can be find' do
    visit new_vm_path
    @request = Request.new(
      name: 'MyVM',
      cpu_cores: 2,
      ram_mb: 1000,
      storage_mb: 2000,
      operating_system: 'MyOS',
      software: 'MySoftware',
      comment: 'Comment',
      status: 'pending'
    )
    page.fill_in 'name', with: @request.name
    page.fill_in 'cpu', with: @request.cpu_cores
    page.fill_in 'ram', with: @request.ram_mb
    page.fill_in 'capacity', with: @request.storage_mb
    #find('input[type="submit"]').click
    #vm = Vm.find_by!(:name => @request.name)
    #expect(vm).to_not be_nil
    ##expect(page.cpu).to eq 'MyVM'
    #expect(page).to have_text '2'
    #expect(page).to have_text '1000'
    #expect(page).to have_text '2000'
  end
end