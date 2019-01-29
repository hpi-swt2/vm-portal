# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'projects/show', type: :view do
  let(:user1) { FactoryBot.create :user }
  let(:user2) { FactoryBot.create :user }
  let(:project) { FactoryBot.create :project, responsible_users: [user1, user2] }
  let(:current_user) { user1 }

  before do
    sign_in current_user
    assign(:project, project)
    render
  end

  context 'if the current user is a responsible user for the project' do
    it 'shows the project name' do
      expect(rendered).to include project.name
    end

    it 'shows all project descriptions' do
      expect(rendered).to include project.description
    end

    it 'shows all project users name' do
      expect(rendered).to include project.responsible_users[0].name
      expect(rendered).to include project.responsible_users[1].name
    end

    it 'has a link to go to the all projects page' do
      expect(rendered).to have_link('All Projects', href: projects_path)
    end

    it 'shows a link to edit the project' do
      expect(rendered).to have_link('Edit', href: edit_project_path(project))
    end
  end

  context 'if the current user is not a responsible user for the project' do
    let(:current_user) { FactoryBot.create :user }
    it 'does not show a link to edit the project' do
      expect(rendered).not_to have_link('Edit', href: edit_project_path(project))
    end
  end
end
