# frozen_string_literal: true

require 'rails_helper'

describe 'projects/index.html.erb', type: :feature do
  let(:project) { FactoryBot.create :project }

  before do
    sign_in user
    project
    visit projects_path
  end

  context 'when the user is an user' do
    let(:user) { FactoryBot.create :user }

    it 'has a link to the project' do
      expect(page).to have_link(project.name, href: project_path(project))
    end

    it 'does not show the button for new project creation' do
      expect(page).not_to have_button(id: 'createNewProjectButton')
    end
  end

  context 'when the user is at least an employee' do
    let(:user) { FactoryBot.create :employee }

    it 'shows the button that leads to new project creation' do
      expect(page).to have_button(id: 'createNewProjectButton')
      click_button(id: 'createNewProjectButton')
      expect(page).to have_current_path(new_project_path)
    end
  end
end
