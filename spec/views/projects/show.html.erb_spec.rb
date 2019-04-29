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

    it 'shows a link to edit the project' do
      expect(rendered).to have_link(href: edit_project_path(project))
    end
  end

  context 'if the current user is not a responsible user for the project' do
    let(:current_user) { FactoryBot.create :user }

    it 'does not show a link to edit the project' do
      expect(rendered).not_to have_link(href: edit_project_path(project))
    end
  end

  context 'with a project that is connected to VM configs' do
    it 'shows names of VMs with links' do
      config = FactoryBot.create :virtual_machine_config, responsible_users: [current_user]
      project.virtual_machine_configs << config
      render
      expect(rendered).to have_link(config.name, href: vm_path(config.name))
    end
  end
end
