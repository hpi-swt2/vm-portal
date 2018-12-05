# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  let(:user) { FactoryBot.create :user }

  before do
    assign(:user, user)
    render
  end

  it 'shows the users first name' do
    expect(rendered).to include user.user_profile.first_name
  end

  it 'shows the users email' do
    expect(rendered).to include user.email
  end

  it 'shows the users last name' do
    expect(rendered).to include user.user_profile.last_name
  end
end
