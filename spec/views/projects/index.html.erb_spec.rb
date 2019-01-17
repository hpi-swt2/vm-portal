# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'projects/index', type: :view do
  let(:project) { FactoryBot.create :project, responsible_users: [FactoryBot.create(:user), FactoryBot.create(:user)] }
  let(:other_project) { FactoryBot.create :project, name: 'Other project', description: 'Other description' }

  before do
    sign_in FactoryBot.create :user

    assign(:projects, [project, other_project])
    render
  end

  it 'shows all project names' do
    expect(rendered).to include project.name
    expect(rendered).to include other_project.name
  end

  it 'shows all project descriptions' do
    expect(rendered).to include project.description
    expect(rendered).to include other_project.description
  end

  it 'shows all project users name' do
    expect(rendered).to include project.responsible_users[0].name
    expect(rendered).to include project.responsible_users[1].name
    expect(rendered).to include other_project.responsible_users[0].name
  end
end
