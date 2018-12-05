# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.erb', type: :view do
  let(:users) do
    [
        FactoryBot.create(:user),
        FactoryBot.create(:user, email: "Joe@joe.de"),
    ]
  end

  before do
    assign(:users, users)
    render
  end

  it 'shows all users first names' do
    expect(rendered).to include users[0].user_profile.first_name
    expect(rendered).to include users[1].user_profile.first_name
  end

  it 'shows all users last names' do
    expect(rendered).to include users[0].user_profile.last_name
    expect(rendered).to include users[1].user_profile.last_name
  end

  it 'shows a list of all users emails' do
    expect(rendered).to include users[0].email
    expect(rendered).to include users[1].email
  end
end
