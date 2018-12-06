# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/new', type: :feature do
  before do
    sign_in FactoryBot.create :user
  end

  context 'when a request is created' do
    it 'has a selection of operating_systems' do
      visit new_request_path
      find_field('Operating System')
    end

    it 'has a additional selection of operating_systems' do
      visit new_operating_system_path
      fill_in('operating_system_name', with: 'MyOS')
      click_button('Create Operating system')
      visit new_request_path
      find_field('Operating System').find(:xpath, 'option[2]').select_option
      expect(find_field('Operating System').value).to eq('MyOS')
    end

    it 'has two possible selections of operating_systems' do
      visit new_request_path
      find_field('Operating System').find(:xpath, 'option[2]').select_option
    end
  end
end
