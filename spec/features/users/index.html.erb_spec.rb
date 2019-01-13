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

    context 'looking at a normal user' do
      before do
        @button_user = page.find(id: "btn-user-#{user.id}")
        @button_employee = page.find(id: "btn-employee-#{user.id}")
        @button_admin = page.find(id: "btn-admin-#{user.id}")
      end

      it 'shows that the role is user' do
        expect(@button_user[:class]).to include 'active'
        expect(@button_employee[:class]).not_to include 'active'
        expect(@button_admin[:class]).not_to include 'active'
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
          expect(@button_employee[:class]).to include 'active'
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
          expect(@button_admin[:class]).to include 'active'
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
        expect(@button_user[:class]).not_to include 'active'
        expect(@button_employee[:class]).to include 'active'
        expect(@button_admin[:class]).not_to include 'active'
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

        it 'shows that employees role is now role' do
          expect(@button_user[:class]).to include 'active'
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
          expect(@button_admin[:class]).to include 'active'
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
        expect(@button_user[:class]).not_to include 'active'
        expect(@button_employee[:class]).not_to include 'active'
        expect(@button_admin[:class]).to include 'active'
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
            expect(@button_admin[:class]).to include 'active'
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
            expect(@button_admin[:class]).to include 'active'
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
