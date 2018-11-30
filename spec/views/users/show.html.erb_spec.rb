# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  before do
    user = FactoryBot.create :user
    puts user.user_profile
    assign(:user, user)
    render()
  end

  it 'shows the users first name' do
    expect(rendered).to include user.user_profile.first_name
  end
end
