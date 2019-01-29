# frozen_string_literal: true

require 'rails_helper'

describe 'projects/new.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:employee) { FactoryBot.create :employee }
  let(:admin) { FactoryBot.create :admin }

  let(:project_name) { 'Name' }
  let(:project_description) { 'Description' }

  def submit_button
    page.find(id: 'submitProjectButton')
  end

  before do
    user
    employee
    admin
  end

  context 'when the user is an user' do
    before do
      sign_in user
      visit new_project_path
    end

    it 'redirects to the dashboard' do
      expect(page).to have_current_path(dashboard_path)
    end
  end

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

    it 'selects the current_user per default' do
      expect(page).to have_select('project[responsible_user_ids][]', selected: employee.email)
    end

    context 'when the name is empty' do
      before do
        fill_in 'project[description]', with: project_description
        page.select employee.email, from: 'project[responsible_user_ids][]'
      end

      context 'when clicking the submit button' do
        it 'shows an error' do
          submit_button.click
          expect(page).to have_text "Name can't be blank"
        end
      end
    end

    context 'when the description is empty' do
      before do
        fill_in 'project[name]', with: project_name
        page.select employee.email, from: 'project[responsible_user_ids][]'
      end

      context 'when clicking the submit button' do
        it 'shows an error' do
          submit_button.click
          expect(page).to have_text "Description can't be blank"
        end
      end
    end

    context 'when there is no responsible user selected' do
      before do
        fill_in 'project[name]', with: project_name
        fill_in 'project[description]', with: project_description
        page.unselect employee.email, from: 'project[responsible_user_ids][]'
      end

      context 'when clicking the submit button' do
        it 'shows an error' do
          submit_button.click
          expect(page).to have_text '1 error'
        end
      end
    end

    context 'when something is not correctly filled' do
      context 'when only multiple responsible users are selected' do
        before do
          page.select employee.email, from: 'project[responsible_user_ids][]'
          page.select admin.email, from: 'project[responsible_user_ids][]'
        end

        context 'when clicking the submit button' do
          it 'still selects the selected responsible user' do
            submit_button.click
            expect(page).to have_select('project[responsible_user_ids][]', selected: [employee.email, admin.email])
          end
        end
      end
    end

    context 'when every field is correctly filled' do
      before do
        fill_in 'project[name]', with: project_name
        fill_in 'project[description]', with: project_description
        page.select employee.email, from: 'project[responsible_user_ids][]'
      end

      context 'when clicking the submit button' do
        before do
          submit_button.click
        end

        it 'redirects to projects/index' do
          expect(page).to have_current_path(projects_path)
        end

        it 'has created the project' do
          project = Project.all.last
          expect(project.name).to eq project_name
          expect(project.description).to eq project_description
          expect(project.responsible_users).to eq [employee]
        end
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in admin
        visit new_project_path
      end

      context 'when every field is correctly filled' do
        before do
          fill_in 'project[name]', with: project_name
          fill_in 'project[description]', with: project_description
          page.select admin.email, from: 'project[responsible_user_ids][]'
        end

        context 'when clicking the submit button' do
          before do
            submit_button.click
          end

          it 'redirects to projects/index' do
            expect(page).to have_current_path(projects_path)
          end

          it 'has created the project' do
            project = Project.all.last
            expect(project.name).to eq project_name
            expect(project.description).to eq project_description
            expect(project.responsible_users).to eq [admin]
          end
        end
      end
    end
  end
end
