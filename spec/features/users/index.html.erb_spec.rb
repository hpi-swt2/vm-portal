# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:admin) {FactoryBot.create :admin}
  let(:employee) {FactoryBot.create :employee}

  context 'when the user is an admin' do
    before do
      sign_in admin
      visit users_path
    end

    it 'shows that the users role is users' do
      expect(page.find_button(id: "btn-user-#{users.id}")).to have_css('active')
      expect(page.find_button(id: "btn-employee-#{users.id}")).not_to have_css('active')
      expect(page.find_button(id: "btn-admin-#{users.id}")).not_to have_css('active')
    end

    # it 'shows that the employee role is employee' do
    #   expect(page.find_button(id: "btn-user-#{employee.id}")).not_to have_css('active')
    #   expect(page.find_button(id: "btn-employee-#{employee.id}")).to have_css('active')
    #   expect(page.find_button(id: "btn-admin-#{employee.id}")).not_to have_css('active')
    # end
    #
    # it 'shows that the admins role is admin' do
    #   expect(page.find_button(id: "btn-user-#{admin.id}")).not_to have_css('active')
    #   expect(page.find_button(id: "btn-employee-#{admin.id}")).not_to have_css('active')
    #   expect(page.find_button(id: "btn-admin-#{admin.id}")).to have_css('active')
    # end
  end
end
