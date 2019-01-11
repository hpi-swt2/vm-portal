# frozen_string_literal: true

require 'rails_helper'

describe 'requests/index.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:employee) { FactoryBot.create :employee }
  let(:admin) { FactoryBot.create :admin }

  let(:request_from_admin) { FactoryBot.create :request, user: admin, name: 'AdminVM'}
  let(:request_from_employee) { FactoryBot.create :request, user: employee, name: 'EmployeeVM'}


  before do
    request_from_admin
    request_from_employee
  end

  context 'when the user is an user' do
    before do
      sign_in user
      visit requests_path
    end

    it 'redirects to the root path' do
      expect(page).to have_current_path(dashboard_path)
    end
  end

  context 'when the user is an admin' do
    before do
      sign_in admin
      visit requests_path
    end

    it 'shows all vms' do
      expect(page).to have_text(request_from_admin.name)
      expect(page).to have_text(request_from_employee.name)
    end
  end

  context 'when the user is an employee' do
    before do
      sign_in employee
      visit requests_path
    end

    it 'shows the employees vm' do
      expect(page).to have_text(request_from_employee.name)
    end

    it 'does not show the admins vm' do
      expect(page).not_to have_text(request_from_admin.name)
    end
  end
end