# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'operating_system selection for request', type: :feature do
  before do
    sign_in FactoryBot.create :user, role: :employee
  end

  it 'has a selection of operating_systems' do
    visit new_request_path
    find_by_id('operating_system')
  end

  it 'has none and other as options' do
    visit new_request_path
    select('other (write in Comment)', from: 'operating_system')
    select('none', from: 'operating_system')
  end

  context 'when operating systems have been created' do
    before do
      # have use the instance variable, because the request has to be created before visiting the page
      @operating_system = FactoryBot.create(:operating_system)
    end

    it 'has an additional selection of operating_systems' do
      visit new_request_path
      select(@operating_system.name, from: 'operating_system')
      expect(find_by_id('operating_system').value).to eq(@operating_system.name)
    end
  end
end
