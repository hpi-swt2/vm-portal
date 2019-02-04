# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }
  let(:employee) { FactoryBot.create :employee }

  context 'when the current_user is not an admin' do
    before do
      sign_in user
      visit users_path
    end

    it 'redirects to the dashboard' do
      expect(page).to have_current_path dashboard_path
    end
  end

  context 'when the current_user is an admin' do
    before do
      user
      employee
      sign_in admin
      visit users_path
    end

    context 'when searching' do
      before do
        @user1 = FactoryBot.create :user, first_name: "test_user_1"
        @user2 = FactoryBot.create :user, first_name: "test_user_2"
        @admin = FactoryBot.create :admin, first_name: "test_admin"
        @employee = FactoryBot.create :employee, first_name: "test_employee"
      end

      context 'all with search' do
        before do
          select "user", :from => "role"
          fill_in "search", :with => "test_user_2"
          click_on "Search"
        end

        it 'does not show user 1' do
          expect(page).not_to have_content("test_user_1")
        end

        it 'show user 1' do
          expect(page).to have_content("test_user_2")
        end

        it 'does not show admins' do
          expect(page).not_to have_content("test_admin")
        end

        it 'does not show employees' do
          expect(page).not_to have_content("test_employee")
        end
      end

      context 'for all' do
        before do
          select "all", :from => "role"
          click_on "Search"
        end

        it 'shows user 1' do
          expect(page).to have_content("test_user_1")
        end

        it 'shows user 2' do
          expect(page).to have_content("test_user_2")
        end

        it 'shows all admins' do
          expect(page).to have_content("test_admin")
        end

        it 'shows all employees' do
          expect(page).to have_content("test_employee")
        end
      end

      context 'for users' do
        before do
          select "user", :from => "role"
          click_on "Search"
        end

        it 'shows all users' do
          expect(page).to have_content("test_user_1")
          expect(page).to have_content("test_user_2")
        end

        it 'does not show admins' do
          expect(page).not_to have_content("test_admin")
        end

        it 'does not show employees' do
          expect(page).not_to have_content("test_employee")
        end
      end

      context 'for admins' do
        before do
          select "admin", :from => "role"
          click_on "Search"
        end

        it 'does not show users' do
          expect(page).not_to have_content("test_user_1")
          expect(page).not_to have_content("test_user_2")
        end

        it 'shows all admins' do
          expect(page).to have_content("test_admin")
        end

        it 'does not show employees' do
          expect(page).not_to have_content("test_employee")
        end
      end

      context 'for employees' do
        before do
          select "employee", :from => "role"
          click_on "Search"
        end

        it 'does not show users' do
          expect(page).not_to have_content("test_user_1")
          expect(page).not_to have_content("test_user_2")
        end

        it 'does not show admins' do
          expect(page).not_to have_content("test_admin")
        end

        it 'shows employees' do
          expect(page).to have_content("test_employee")
        end
      end
    end
    context 'looking at a normal user' do
      before do
        @button_user = page.find(id: "btn-user-#{user.id}")
        @button_employee = page.find(id: "btn-employee-#{user.id}")
        @button_admin = page.find(id: "btn-admin-#{user.id}")
      end

      it 'shows that the role is user' do
        expect(@button_user[:class]).to include 'primary'
        expect(@button_employee[:class]).not_to include 'primary'
        expect(@button_admin[:class]).not_to include 'primary'
      end

      context 'clicking the employee button' do
        before do
          @button_employee.click
          user.reload
          @button_employee = page.find(id: "btn-employee-#{user.id}")
        end

        it 'updates the users role to employee' do
          expect(user.role).to eq 'employee'
        end

        it 'shows that users role is now employee' do
          expect(@button_employee[:class]).to include 'primary'
        end
      end

      context 'clicking the admin button' do
        before do
          @button_admin.click
          user.reload
          @button_admin = page.find(id: "btn-admin-#{user.id}")
        end

        it 'updates the users role to admin' do
          expect(user.role).to eq 'admin'
        end

        it 'shows that users role is now admin' do
          expect(@button_admin[:class]).to include 'primary'
        end
      end
    end

    context 'looking at an employee' do
      before do
        @button_user = page.find(id: "btn-user-#{employee.id}")
        @button_employee = page.find(id: "btn-employee-#{employee.id}")
        @button_admin = page.find(id: "btn-admin-#{employee.id}")
      end

      it 'shows that the role is employee' do
        expect(@button_user[:class]).not_to include 'primary'
        expect(@button_employee[:class]).to include 'primary'
        expect(@button_admin[:class]).not_to include 'primary'
      end

      context 'clicking the user button' do
        before do
          @button_user.click
          employee.reload
          @button_user = page.find(id: "btn-user-#{employee.id}")
        end

        it 'updates the employees role to user' do
          expect(employee.role).to eq 'user'
        end

        it 'shows that employees role is now user' do
          expect(@button_user[:class]).to include 'primary'
        end
      end

      context 'clicking the admin button' do
        before do
          @button_admin.click
          employee.reload
          @button_admin = page.find(id: "btn-admin-#{employee.id}")
        end

        it 'updates the users role to admin' do
          expect(employee.role).to eq 'admin'
        end

        it 'shows that users role is now admin' do
          expect(@button_admin[:class]).to include 'primary'
        end
      end
    end

    context 'looking at an admin' do
      before do
        @button_user = page.find(id: "btn-user-#{admin.id}")
        @button_employee = page.find(id: "btn-employee-#{admin.id}")
        @button_admin = page.find(id: "btn-admin-#{admin.id}")
      end

      it 'shows that the role is admin' do
        expect(@button_user[:class]).not_to include 'secondary'
        expect(@button_employee[:class]).not_to include 'secondary'
        expect(@button_admin[:class]).to include 'secondary'
      end

      context 'when there is only one admin' do
        before do
          assert User.all.select(&:admin?).size == 1
        end

        it 'disables all buttons' do
          expect(@button_user[:class]).to include 'disabled'
          expect(@button_employee[:class]).to include 'disabled'
          expect(@button_admin[:class]).to include 'disabled'
        end

        context 'clicking the user button' do
          before do
            @button_user.click
            admin.reload
            @button_admin = page.find(id: "btn-admin-#{admin.id}")
          end

          it 'does not update the admins role' do
            expect(admin.role).to eq 'admin'
          end

          it 'shows that admins role is still admin' do
            expect(@button_admin[:class]).to include 'secondary'
          end
        end

        context 'clicking the employee button' do
          before do
            @button_employee.click
            admin.reload
            @button_admin = page.find(id: "btn-admin-#{admin.id}")
          end

          it 'does not update the admins role' do
            expect(admin.role).to eq 'admin'
          end

          it 'shows that admins role is still admin' do
            expect(@button_admin[:class]).to include 'secondary'
          end
        end
      end

      context 'when there are multiple admins' do
        before do
          FactoryBot.create :admin
          visit users_path
          @button_user = page.find(id: "btn-user-#{admin.id}")
          @button_employee = page.find(id: "btn-employee-#{admin.id}")
          @button_admin = page.find(id: "btn-admin-#{admin.id}")
        end

        it 'disables no button' do
          expect(@button_user[:class]).not_to include 'disabled'
          expect(@button_employee[:class]).not_to include 'disabled'
          expect(@button_admin[:class]).not_to include 'disabled'
        end

        context 'clicking the user button' do
          before do
            @button_user.click
            admin.reload
          end

          it 'does update the admins role to user' do
            expect(admin.role).to eq 'user'
          end

          it 'hides the role columns' do
            expect(page).not_to have_content 'Role'
          end
        end

        context 'clicking the employee button' do
          before do
            @button_employee.click
            admin.reload
          end

          it 'does update the admins role to employee' do
            expect(admin.role).to eq 'employee'
          end

          it 'hides the role columns' do
            expect(page).not_to have_content 'Role'
          end
        end
      end
    end
  end
end
