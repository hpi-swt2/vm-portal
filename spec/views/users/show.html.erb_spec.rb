# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  let(:user) { FactoryBot.create :user }

  before do
    assign(:user, user)
    allow(view).to receive(:current_user).and_return(user)
    render
  end

  it 'shows the users first name' do
    expect(rendered).to include user.first_name
  end

  it 'shows the users email' do
    expect(rendered).to include user.email
  end

  it 'shows the users last name' do
    expect(rendered).to include user.last_name
  end

  context 'when the user has a ssh key' do
    it 'shows the ssh key' do
      expect(rendered).to include user.ssh_key
    end

    it 'shows a button for editing' do
      expect(rendered).to have_button('Edit')
    end
  end

  context 'when the user has no ssh key' do
    let(:user) { FactoryBot.create :user, ssh_key: '' }

    it 'shows a button for adding' do
      expect(rendered).to have_button('Add')
    end
  end
end
