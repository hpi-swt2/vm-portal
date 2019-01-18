# frozen_string_literal: true

require 'rails_helper'

describe 'projects/edit.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:employee) { FactoryBot.create :employee }
  let(:admin) { FactoryBot.create :admin }

  let(:project) { FactoryBot.create :project, responsible_users: [employee, admin] }
  let(:project_name) { 'Name' }
  let(:project_description) { 'Description' }

  def submit_button
    page.find(id: 'submitProjectButton')
  end

  before do
    user
    employee
    admin
    project
    sign_in current_user
    visit edit_project_path(project)
  end

  context 'when the user is not a responsible user' do
    let(:current_user) { user }

    it 'redirects to the dashboard' do
      expect(page).to have_current_path(dashboard_path)
    end
  end

  context 'when the user a responsible user' do
    let(:current_user) { employee }

    it 'shows a field for the name' do
      expect(page).to have_field 'project[name]'
    end

    it 'shows a field for the description' do
      expect(page).to have_field 'project[description]'
    end

    it 'shows a field for the responsible users' do
      expect(page).to have_select 'project[responsible_user_ids][]'
    end

    it 'shows the current responsible users' do
      expect(page).to have_select('project[responsible_user_ids][]', selected: [employee.email, admin.email])
    end

    context 'when the name is empty' do
      before do
        fill_in 'project[name]', with: ''
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
        fill_in 'project[description]', with: ''
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
        page.unselect employee.email, from: 'project[responsible_user_ids][]'
        page.unselect admin.email, from: 'project[responsible_user_ids][]'
      end

      context 'when clicking the submit button' do
        it 'shows an error' do
          submit_button.click
          expect(page).to have_text '1 error'
        end
      end
    end

    context 'when every field is correctly filled' do
      before do
        fill_in 'project[name]', with: project_name
        fill_in 'project[description]', with: project_description
        page.unselect employee.email, from: 'project[responsible_user_ids][]'
        page.unselect admin.email, from: 'project[responsible_user_ids][]'
        page.select user.email, from: 'project[responsible_user_ids][]'
      end

      context 'when clicking the submit button' do
        before do
          submit_button.click
        end

        it 'redirects to projects' do
          expect(page).to have_current_path(project_path(project))
        end

        it 'has created the project' do
          project.reload
          expect(project.name).to eq project_name
          expect(project.description).to eq project_description
          expect(project.responsible_users).to eq [user]
        end
      end
    end
  end
end
