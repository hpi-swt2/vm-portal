# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'projects/show', type: :view do
  let(:user1) { FactoryBot.create :user }
  let(:user2) { FactoryBot.create :user }
  let(:project) { FactoryBot.create :project, responsible_users: [user1, user2] }

  before do
    sign_in user1
    assign(:project, project)
    render
  end

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
end
