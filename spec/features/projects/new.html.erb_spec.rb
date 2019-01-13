# frozen_string_literal: true

require 'rails_helper'

describe 'projects/new.html.erb', type: :feature do
  let(:employee) { FactoryBot.create :employee }


  context 'when the user is an employee' do
    before do
      sign_in employee
      visit new_project_path
    end

    it 'shows a field for the name' do
      expect(page).to have_field 'project[name]'
    end

    it 'shows a field for the description' do
      expect(page).to have_field 'project[description]'
    end

    it 'shows a field for the responsible_users' do
      expect(page).to have_select 'project[responsible_user_ids][]'
    end
  end
end
