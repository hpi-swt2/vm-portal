# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.erb', type: :view do
  let(:users) do
    [
      FactoryBot.create(:user),
      FactoryBot.create(:user, email: Faker::Internet.safe_email('joe'))
    ]
  end

  before do
    assign(:users, users)
    render
  end

  it 'shows all users first name' do
    expect(rendered).to include users[0].name
    expect(rendered).to include users[1].name
  end

  it 'shows a list of all users emails' do
    expect(rendered).to include users[0].email
    expect(rendered).to include users[1].email
  end
end
