# frozen_string_literal: true

require 'rails_helper'

describe 'requests/new.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:user2) { FactoryBot.create :user }
  let(:employee) { FactoryBot.create :employee }
  let(:admin) { FactoryBot.create :admin }

  def submit_button
    page.find(id: 'submitRequestButton')
  end

  before do
    user
    user2
    admin
    sign_in employee
    visit new_request_path
  end

  context 'when filling out the template correctly' do
    before do
      fill_in 'request[name]', with: 'name'
      fill_in 'request[cpu_cores]', with: '1'
      fill_in 'request[ram_mb]', with: '1'
      fill_in 'request[storage_mb]', with: '1'
      fill_in 'request[cpu_cores]', with: '1'
      fill_in 'request[ram_mb]', with: '1'
      fill_in 'request[storage_mb]', with: '1'
      page.select user.email, from: 'request[sudo_user_ids][]'
      page.select employee.email, from: 'request[sudo_user_ids][]'
      page.select user2.email, from: 'request[user_ids][]'
      page.select admin.email, from: 'request[user_ids][]'
      fill_in 'request[port]', with: '8080'
      fill_in 'request[application_name]', with: 'name'
      fill_in 'request[description]', with: 'Very descriptive text'
    end

    context 'when clicking the submit button' do
      let(:request) { Request.last }

      before do
        submit_button.click
      end

      it 'adds the correct users' do
        expect(request.users).to include user
        expect(request.users).to include user2
        expect(request.users).to include employee
        expect(request.users).to include admin
      end
    end
  end

  it 'has a selection of operating_systems' do
    find_by_id('operating_system')
  end

  it 'has none and other as options' do
    select('other (write in Comment)', from: 'operating_system')
    select('none', from: 'operating_system')
  end

  context 'when operating systems have been created' do
    let(:operating_system) { FactoryBot.create(:operating_system) }

    before do
      operating_system
      visit new_request_path
    end

    it 'has an additional selection of operating_systems' do
      select(operating_system.name, from: 'operating_system')
      expect(find_by_id('operating_system').value).to eq(operating_system.name)
    end
  end
end
