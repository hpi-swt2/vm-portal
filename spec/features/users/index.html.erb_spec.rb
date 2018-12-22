# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }
  let(:employee) { FactoryBot.create :employee }

  context 'when the current_user is an admin' do
    before do
      user
      employee
      sign_in admin
      visit users_path
    end

    it 'shows that an users role is users' do
      expect(page.find(id: "btn-user-#{user.id}")[:class]).to include 'active'
      expect(page.find(id: "btn-employee-#{user.id}")[:class]).not_to include 'active'
      expect(page.find(id: "btn-admin-#{user.id}")[:class]).not_to include 'active'
    end

    it 'shows that an employees role is employee' do
      expect(page.find(id: "btn-user-#{employee.id}")[:class]).not_to include 'active'
      expect(page.find(id: "btn-employee-#{employee.id}")[:class]).to include 'active'
      expect(page.find(id: "btn-admin-#{employee.id}")[:class]).not_to include 'active'
    end

    it 'shows that an admins role is admin' do
      expect(page.find(id: "btn-user-#{admin.id}")[:class]).not_to include 'active'
      expect(page.find(id: "btn-employee-#{admin.id}")[:class]).not_to include 'active'
      expect(page.find(id: "btn-admin-#{admin.id}")[:class]).to include 'active'
    end
  end
end
